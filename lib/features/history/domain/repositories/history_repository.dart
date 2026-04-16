import 'package:movers/features/home/domain/entities/job_entity.dart';

abstract class HistoryRepository {
  Future<List<JobEntity>> getCompletedJobs({int page = 1});
}
