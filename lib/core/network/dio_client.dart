import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_interceptor.dart';

class DioClient {
  final Dio dio;
  final FlutterSecureStorage storage;

  DioClient({
    Dio? dioOverride,
    required this.storage,
    void Function()? onLogout,
  }) : dio = dioOverride ?? Dio() {
    dio
      ..options.baseUrl = dotenv.get(
        'API_BASE_URL',
        fallback: 'https://movers-backend.learnica.net',
      )
      ..options.connectTimeout = const Duration(seconds: 45)
      ..options.receiveTimeout = const Duration(seconds: 45)
      ..options.responseType = ResponseType.json;

    dio.interceptors.add(AuthInterceptor(storage, onLogout: onLogout));
  }
}
