import 'package:dio/dio.dart';
import 'package:movers/core/network/dio_client.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/entities/home_status_counts.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/job_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final DioClient _dioClient;

  HomeRepositoryImpl(this._dioClient);

  @override
  Future<List<JobEntity>> getMyJobs({
    int page = 1,
    String? status,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _dioClient.dio.get(
        '/api/v1/dispatch/my-jobs',
        queryParameters: queryParams,
      );

      // LoggerUtils.logJson('My Jobs API Response', response.data);

      if (response.statusCode == 200) {
        final data =
            response.data['data']; // Using 'data' array from paginated response
        return (data as List).map((json) => JobModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch jobs',
        );
      }
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<HomeStatusCounts> getMyJobsCounts({
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _dioClient.dio.get(
        '/api/v1/dispatch/my-jobs/counts',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return HomeStatusCounts.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch job counts',
        );
      }
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> confirmAssignment(int crewAssignmentId, String status) async {
    try {
      final response = await _dioClient.dio.patch(
        '/api/v1/dispatch/crew/$crewAssignmentId',
        data: {'status': status},
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to confirm assignment',
        );
      }
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
