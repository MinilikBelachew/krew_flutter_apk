import 'package:dio/dio.dart';
import 'package:movers/core/network/dio_client.dart';
import 'package:movers/features/history/domain/repositories/history_repository.dart';
import 'package:movers/features/home/data/models/job_model.dart';
import 'package:movers/features/home/domain/entities/job_entity.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final DioClient _dioClient;

  HistoryRepositoryImpl(this._dioClient);

  @override
  Future<List<JobEntity>> getCompletedJobs({int page = 1}) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/v1/dispatch/my-jobs',
        queryParameters: {
          'status': 'completed',
          'page': page,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => JobModel.fromJson(json)).toList();
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to fetch history jobs',
      );
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
