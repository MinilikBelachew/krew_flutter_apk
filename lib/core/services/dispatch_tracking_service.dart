import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';

import '../network/dio_client.dart';

class DispatchTrackingService {
  final FlutterSecureStorage _storage;
  final DioClient _dioClient;

  Timer? _timer;
  int? _jobId;
  bool _isSending = false;

  DispatchTrackingService({
    required FlutterSecureStorage storage,
    required DioClient dioClient,
  }) : _storage = storage,
       _dioClient = dioClient;

  bool get isTracking => _timer != null;

  Future<void> start({required int jobId}) async {
    if (_timer != null) return;

    _jobId = jobId;
    await _storage.write(key: 'active_tracking_job_id', value: jobId.toString());

    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('Location services are disabled');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    if (kDebugMode) {
      // ignore: avoid_print
      print('📍 [DispatchTrackingService] Tracking started (jobId=$jobId)');
    }

    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      _tick();
    });

    await _tick();
  }

  Future<void> _tick() async {
    final currentJobId = _jobId;
    if (currentJobId == null) return;
    if (_isSending) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('⏳ [DispatchTrackingService] skip tick (in-flight request)');
      }
      return;
    }

    _isSending = true;
    try {
      final pos = await Geolocator.getCurrentPosition(                                                                                                                                                                                                                                                                                                                                                                                               
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );

      final payload = {
        'jobId': currentJobId,
        'lat': pos.latitude,
        'lng': pos.longitude,
        'accuracy': pos.accuracy,
        'speed': pos.speed,
        'heading': pos.heading,
        'ts': pos.timestamp.millisecondsSinceEpoch,
      };

      if (kDebugMode) {
        // ignore: avoid_print
        print(
          '📡 [DispatchTrackingService] send location jobId=$currentJobId lat=${pos.latitude} lng=${pos.longitude}',
        );
        // ignore: avoid_print
        print('📦 [DispatchTrackingService] payload=$payload');
      }

      final resp = await _dioClient.dio.post(
        '/api/v1/dispatch/mobile/location',
        data: payload,
      );

      if (kDebugMode) {
        // ignore: avoid_print
        print(
          '✅ [DispatchTrackingService] sent (status=${resp.statusCode})',
        );
        // ignore: avoid_print
        print('📥 [DispatchTrackingService] response=${resp.data}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print(
          '❌ [DispatchTrackingService] send failed: status=${e.response?.statusCode} data=${e.response?.data} error=$e',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('❌ [DispatchTrackingService] tick error: $e');
      }
    } finally {
      _isSending = false;
    }
  }

  Future<void> stop() async {
    _jobId = null;
    final timer = _timer;
    _timer = null;
    timer?.cancel();
    await _storage.delete(key: 'active_tracking_job_id');

    if (kDebugMode) {
      // ignore: avoid_print
      print('🛑 [DispatchTrackingService] Tracking stopped');
    }
  }

  Future<void> persistEnabled(bool enabled) async {
    await _storage.write(key: 'tracking_enabled', value: enabled ? 'true' : 'false');
  }

  Future<bool> isEnabled() async {
    final v = await _storage.read(key: 'tracking_enabled');
    return v == 'true';
  }

  Future<void> autoResume() async {
    if (!await isEnabled()) return;
    try {
      final jobIdStr = await _storage.read(key: 'active_tracking_job_id');
      if (jobIdStr != null) {
        final id = int.tryParse(jobIdStr);
        if (id != null) {
          if (kDebugMode) {
            // ignore: avoid_print
            print('🔄 [DispatchTrackingService] Auto-resuming job $id');
          }
          await start(jobId: id);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('❌ [DispatchTrackingService] autoResume failed: $e');
      }
    }
  }
}
