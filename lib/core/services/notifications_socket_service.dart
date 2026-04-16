import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'local_notifications_service.dart';

class NotificationsSocketService {
  static final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get notificationsStream =>
      _notificationController.stream;

  final FlutterSecureStorage _storage;

  io.Socket? _socket;
  StreamSubscription? _connectSub;

  NotificationsSocketService({required FlutterSecureStorage storage})
    : _storage = storage;

  Future<void> connect() async {
    if (_socket != null) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ℹ️ [NotificationsSocketService] already initialized');
      }
      if (!(_socket!.connected)) {
        _socket!.connect();
      }
      return;
    }

    final rawBaseUrl = dotenv.get(
      'API_BASE_URL',
      fallback: 'https://movers-backend.learnica.net',
    );

    final baseUrl = rawBaseUrl.endsWith('/')
        ? rawBaseUrl.substring(0, rawBaseUrl.length - 1)
        : rawBaseUrl;

    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('⚠️ [NotificationsSocketService] No access token; skip connect');
      }
      return;
    }

    final url = '$baseUrl/notifications';

    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          // Nest gateway supports auth token via handshake.auth.token or headers.
          .setAuth({'token': 'Bearer $token'})
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    _socket!.onConnect((_) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('✅ [NotificationsSocketService] connected');
      }
      _socket!.emitWithAck('join', null, ack: (dynamic res) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('✅ [NotificationsSocketService] join ack: $res');
        }
      });
    });

    _socket!.onDisconnect((_) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('⚠️ [NotificationsSocketService] disconnected');
      }
    });

    _socket!.onConnectError((e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('❌ [NotificationsSocketService] connect error: $e');
      }
    });

    _socket!.onError((e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('❌ [NotificationsSocketService] error: $e');
      }
    });

    _socket!.on('notification', (dynamic payload) async {
      try {
        if (kDebugMode) {
          // ignore: avoid_print
          print('📩 [NotificationsSocketService] notification: $payload');
        }

        if (payload is Map) {
          _notificationController.add(Map<String, dynamic>.from(payload));
        }

        final title = (payload is Map && payload['title'] != null)
            ? payload['title'].toString()
            : 'Notification';

        final rawBody = (payload is Map && payload['body'] != null)
            ? payload['body'].toString()
            : '';

        // Strip out the user name which appears inside parentheses e.g. "(John Doe)" 
        // to match the privacy hiding mechanism used in the top nav NotificationsPage.
        final body = rawBody.replaceAll(RegExp(r'\([^)]+\)'), '').replaceAll('  ', ' ').trim();

        await LocalNotificationsService.instance.show(title: title, body: body);
      } catch (e) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('⚠️ [NotificationsSocketService] handle notification failed: $e');
        }
      }
    });

    _socket!.on('joined', (dynamic payload) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('✅ [NotificationsSocketService] joined event: $payload');
      }
    });

    _socket!.connect();

    // keep something referenced to avoid analyzer removing future usage
    _connectSub ??= const Stream<void>.empty().listen(null);
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }
}
