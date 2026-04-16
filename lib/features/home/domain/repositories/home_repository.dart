import '../entities/job_entity.dart';
import '../entities/home_status_counts.dart';

abstract class HomeRepository {
  Future<List<JobEntity>> getMyJobs({
    int page = 1,
    String? status,
    String? search,
  });

  Future<HomeStatusCounts> getMyJobsCounts({
    String? search,
  });

  Future<void> confirmAssignment(int crewAssignmentId, String status);
}
