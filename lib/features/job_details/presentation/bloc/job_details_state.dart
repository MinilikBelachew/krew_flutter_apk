import 'package:equatable/equatable.dart';
import 'package:movers/features/job_details/domain/entities/job_detail_entity.dart';

enum JobDetailsTab { jobInfo, inventory, packing, photos }

class JobDetailsState extends Equatable {
  final JobDetailEntity? job;
  final JobDetailsTab activeTab;
  final bool isLoading;
  final bool isUpdatingStatus;
  final bool isTogglingClock;
  final bool isLoadingFiles;
  final String? errorMessage;
  final bool showMap;
  final Set<String> expandedSections;
  final List<JobFile> jobFiles;
  final Map<String, DateTime> statusTimestamps;
  final int currentPickupIndex;
  final int currentDeliveryIndex;
  final Set<String> checkedInventoryKeys;
  final Set<String> checkedPackingKeys;

  const JobDetailsState({
    this.job,
    this.activeTab = JobDetailsTab.jobInfo,
    this.isLoading = false,
    this.isUpdatingStatus = false,
    this.isTogglingClock = false,
    this.isLoadingFiles = false,
    this.showMap = false,
    this.errorMessage,
    this.expandedSections = const {'Notes', 'Materials', 'Bulky items'},
    this.jobFiles = const [],
    this.statusTimestamps = const {},
    this.currentPickupIndex = 0,
    this.currentDeliveryIndex = 0,
    this.checkedInventoryKeys = const {},
    this.checkedPackingKeys = const {},
  });

  @override
  List<Object?> get props => [
    job,
    activeTab,
    isLoading,
    isUpdatingStatus,
    isTogglingClock,
    isLoadingFiles,
    showMap,
    errorMessage,
    expandedSections,
    expandedSections,
    jobFiles,
    statusTimestamps,
    currentPickupIndex,
    currentDeliveryIndex,
    checkedInventoryKeys,
    checkedPackingKeys,
  ];

  JobDetailsState copyWith({
    JobDetailEntity? job,
    JobDetailsTab? activeTab,
    bool? isLoading,
    bool? isUpdatingStatus,
    bool? isTogglingClock,
    bool? isLoadingFiles,
    bool? showMap,
    String? errorMessage,
    Set<String>? expandedSections,
    List<JobFile>? jobFiles,
    Map<String, DateTime>? statusTimestamps,
    int? currentPickupIndex,
    int? currentDeliveryIndex,
    Set<String>? checkedInventoryKeys,
    Set<String>? checkedPackingKeys,
  }) {
    return JobDetailsState(
      job: job ?? this.job,
      activeTab: activeTab ?? this.activeTab,
      isLoading: isLoading ?? this.isLoading,
      isUpdatingStatus: isUpdatingStatus ?? this.isUpdatingStatus,
      isTogglingClock: isTogglingClock ?? this.isTogglingClock,
      isLoadingFiles: isLoadingFiles ?? this.isLoadingFiles,
      showMap: showMap ?? this.showMap,
      errorMessage: errorMessage ?? this.errorMessage,
      expandedSections: expandedSections ?? this.expandedSections,
      jobFiles: jobFiles ?? this.jobFiles,
      statusTimestamps: statusTimestamps ?? this.statusTimestamps,
      currentPickupIndex: currentPickupIndex ?? this.currentPickupIndex,
      currentDeliveryIndex: currentDeliveryIndex ?? this.currentDeliveryIndex,
      checkedInventoryKeys: checkedInventoryKeys ?? this.checkedInventoryKeys,
      checkedPackingKeys: checkedPackingKeys ?? this.checkedPackingKeys,
    );
  }
}
