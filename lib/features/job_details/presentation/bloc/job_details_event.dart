import 'package:equatable/equatable.dart';
import 'package:movers/features/job_details/presentation/bloc/job_details_state.dart';

abstract class JobDetailsEvent extends Equatable {
  const JobDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadJobDetails extends JobDetailsEvent {
  final String jobId;
  const LoadJobDetails(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class ChangeTab extends JobDetailsEvent {
  final JobDetailsTab tab;
  const ChangeTab(this.tab);

  @override
  List<Object?> get props => [tab];
}

class UpdateStatus extends JobDetailsEvent {
  final String newStatus;
  final int? etaMinutes;
  final bool skipContractCheck;
  const UpdateStatus(this.newStatus, {this.etaMinutes, this.skipContractCheck = false});

  @override
  List<Object?> get props => [newStatus, etaMinutes, skipContractCheck];
}

class MarkArrivedAtHq extends JobDetailsEvent {
  final String jobId;
  const MarkArrivedAtHq(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class ToggleSection extends JobDetailsEvent {
  final String sectionName;
  const ToggleSection(this.sectionName);

  @override
  List<Object?> get props => [sectionName];
}

class ToggleMap extends JobDetailsEvent {
  const ToggleMap();
}

class UploadJobFiles extends JobDetailsEvent {
  final List<String> filePaths;
  const UploadJobFiles(this.filePaths);

  @override
  List<Object?> get props => [filePaths];
}

class FetchJobFiles extends JobDetailsEvent {
  final String jobId;
  const FetchJobFiles(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class ToggleJobClock extends JobDetailsEvent {
  final String jobId;
  final String crewAssignmentId;
  final String action; // 'clock-in' or 'clock-out'
  const ToggleJobClock({
    required this.jobId,
    required this.crewAssignmentId,
    required this.action,
  });

  @override
  List<Object?> get props => [jobId, crewAssignmentId, action];
}

class ToggleInventoryItem extends JobDetailsEvent {
  final String jobId;
  final String itemKey;
  const ToggleInventoryItem(this.jobId, this.itemKey);

  @override
  List<Object?> get props => [jobId, itemKey];
}

class TogglePackingItem extends JobDetailsEvent {
  final String jobId;
  final String itemKey;
  const TogglePackingItem(this.jobId, this.itemKey);

  @override
  List<Object?> get props => [jobId, itemKey];
}

