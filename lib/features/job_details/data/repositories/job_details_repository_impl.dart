import '../../domain/entities/job_detail_entity.dart';
import '../../domain/repositories/job_details_repository.dart';
import '../datasources/job_details_remote_data_source.dart';

class JobDetailsRepositoryImpl implements JobDetailsRepository {
  final JobDetailsRemoteDataSource _remoteDataSource;

  JobDetailsRepositoryImpl(this._remoteDataSource);

  @override
  Future<JobDetailEntity> getJobDetails(String id) async {
    return await _remoteDataSource.getJobDetails(id);
  }

  @override
  Future<void> updateJobWorkflowStatus(
    String id,
    String status, {
    int? etaMinutes,
    bool skipContractCheck = false,
  }) async {
    return await _remoteDataSource.updateJobWorkflowStatus(
      id,
      status,
      etaMinutes: etaMinutes,
      skipContractCheck: skipContractCheck,
    );
  }

  @override
  Future<void> markArrivedAtHq(String id) async {
    return await _remoteDataSource.markArrivedAtHq(id);
  }

  @override
  Future<void> updateClockStatus(String crewAssignmentId, String action) async {
    return await _remoteDataSource.updateClockStatus(crewAssignmentId, action);
  }

  @override
  Future<void> updateJobClockStatus(String jobId, String action) async {
    return await _remoteDataSource.updateJobClockStatus(jobId, action);
  }

  @override
  Future<void> uploadJobFiles(String jobId, List<String> filePaths) async {
    return await _remoteDataSource.uploadJobFiles(jobId, filePaths);
  }

  @override
  Future<List<Map<String, dynamic>>> getJobFiles(String jobId) async {
    return await _remoteDataSource.getJobFiles(jobId);
  }
}
