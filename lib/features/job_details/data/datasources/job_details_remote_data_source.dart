import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/dio_client.dart';
import '../models/job_details_model.dart';
import '../../../../core/services/dispatch_tracking_service.dart';

abstract class JobDetailsRemoteDataSource {
  Future<JobDetailsModel> getJobDetails(String id);
  Future<void> updateJobWorkflowStatus(
    String id,
    String status, {
    int? etaMinutes,
    bool skipContractCheck = false,
  });
  Future<void> markArrivedAtHq(String id);
  Future<void> updateClockStatus(String crewAssignmentId, String action);
  Future<void> updateJobClockStatus(String jobId, String action);
  Future<void> uploadJobFiles(String jobId, List<String> filePaths);
  Future<List<Map<String, dynamic>>> getJobFiles(String jobId);
}

class JobDetailsRemoteDataSourceImpl implements JobDetailsRemoteDataSource {
  final DioClient _dioClient;
  final DispatchTrackingService _dispatchTrackingService;

  JobDetailsRemoteDataSourceImpl(this._dioClient)
    : _dispatchTrackingService = DispatchTrackingService(
        storage: const FlutterSecureStorage(),
        dioClient: _dioClient,
      );

  @override
  Future<JobDetailsModel> getJobDetails(String id) async {
    try {
      final response = await _dioClient.dio.get('/api/v1/dispatch/jobs/$id');
      debugPrint('[JobDetailsDataSource] getJobDetails response=${jsonEncode(response.data)}');
      return JobDetailsModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateJobWorkflowStatus(
    String id,
    String status, {
    int? etaMinutes,
    bool skipContractCheck = false,
  }) async {
    final statusMap = {
      'En route': 'EN_ROUTE_TO_PICKUP',
      'Arrived': 'AT_PICKUP',
      'Loading': 'LOADING',
      'Loaded': 'EN_ROUTE_TO_DELIVERY',
      'Delivery': 'AT_DELIVERY',
      'Unload': 'UNLOADING',
      'Completed': 'COMPLETED',
    };

    final backendStatus = statusMap[status] ?? status;

    final data = <String, dynamic>{
      'status': backendStatus,
      'skipContractCheck': skipContractCheck,
    };
    if (etaMinutes != null) {
      data['etaMinutes'] = etaMinutes;
    }

    try {
      await _dioClient.dio.patch(
        '/api/v1/dispatch/jobs/$id/workflow-status',
        data: data,
      );

      final trackingEnabled = await _dispatchTrackingService.isEnabled();
      if (trackingEnabled) {
        if (backendStatus == 'EN_ROUTE_TO_PICKUP') {
          await _dispatchTrackingService.start(jobId: int.parse(id));
        } else if (backendStatus == 'COMPLETED') {
          await _dispatchTrackingService.stop();
        }
      }

      if (backendStatus == 'EN_ROUTE_TO_PICKUP') {
        try {
          await _dioClient.dio.patch(
            '/api/v1/dispatch/jobs/$id/status',
            data: {'action': 'clock-in'},
          );
        } on DioException catch (e) {
          final msg = (e.response?.data is Map)
              ? (e.response?.data['message']?.toString() ?? '')
              : '';
          if (e.response?.statusCode == 400 &&
              msg.toLowerCase().contains('already clocked')) {
            // Ignore idempotency error.
          } else {
            rethrow;
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markArrivedAtHq(String id) async {
    try {
      const payload = <String, dynamic>{};
      final url = '/api/v1/dispatch/jobs/$id/arrived-at-hq';
      debugPrint('[markArrivedAtHq] PATCH $url payload=${jsonEncode(payload)}');

      final response = await _dioClient.dio.patch(url, data: payload);
      debugPrint(
        '[markArrivedAtHq] response status=${response.statusCode} data=${jsonEncode(response.data)}',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateClockStatus(String crewAssignmentId, String action) async {
    try {
      debugPrint('[JobDetailsDataSource] updateClockStatus crew: $crewAssignmentId, action: $action');
      await _dioClient.dio.patch(
        '/api/v1/dispatch/crew/$crewAssignmentId',
        data: {'action': action},
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateJobClockStatus(String jobId, String action) async {
    try {
      await _dioClient.dio.patch(
        '/api/v1/dispatch/jobs/$jobId/status',
        data: {'action': action},
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> uploadJobFiles(String jobId, List<String> filePaths) async {
    try {
      final formData = FormData();
      for (final path in filePaths) {
        formData.files.add(
          MapEntry('files', await MultipartFile.fromFile(path)),
        );
      }
      await _dioClient.dio.post(
        '/api/v1/dispatch/jobs/$jobId/files',
        data: formData,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getJobFiles(String jobId) async {
    final response = await _dioClient.dio.get(
      '/api/v1/dispatch/jobs/$jobId/files',
    );
    final data = response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
