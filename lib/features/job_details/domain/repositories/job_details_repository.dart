import '../../domain/entities/job_detail_entity.dart';

abstract class JobDetailsRepository {
  Future<JobDetailEntity> getJobDetails(String id);
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
