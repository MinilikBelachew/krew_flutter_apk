import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/job_detail_entity.dart';
import '../../domain/repositories/job_details_repository.dart';
import '../../../../core/services/map_service.dart';
import 'job_details_event.dart';
import 'job_details_state.dart';

class JobDetailsBloc extends Bloc<JobDetailsEvent, JobDetailsState> {
  final JobDetailsRepository _repository;
  final MapService _mapService = MapService();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static String _tsKey(String jobId, String status) =>
      'job_status_ts_${jobId}_$status';

  static String _pickupIdxKey(String jobId) => 'job_pickup_idx_$jobId';
  static String _deliveryIdxKey(String jobId) => 'job_delivery_idx_$jobId';
  static String _invKey(String jobId) => 'job_inv_checks_$jobId';
  static String _packKey(String jobId) => 'job_pack_checks_$jobId';

  Future<Map<String, DateTime>> _loadLocalTimestamps(String jobId) async {
    final Map<String, DateTime> out = {};
    for (final s in const [
      'Arrived',
      'Loading',
      'Loaded',
      'Delivery',
      'Unload',
      'Arrived at HQ',
    ]) {
      final raw = await _storage.read(key: _tsKey(jobId, s));
      if (raw == null || raw.isEmpty) continue;
      final dt = DateTime.tryParse(raw);
      if (dt != null) out[s] = dt;
    }
    return out;
  }

  Future<void> _onMarkArrivedAtHq(
    MarkArrivedAtHq event,
    Emitter<JobDetailsState> emit,
  ) async {
    if (state.job == null) return;
    emit(state.copyWith(isUpdatingStatus: true, errorMessage: null));
    try {
      await _repository.markArrivedAtHq(event.jobId);
      await _storage.write(
        key: _tsKey(event.jobId, 'Arrived at HQ'),
        value: DateTime.now().toIso8601String(),
      );
      final updatedJob = await _repository.getJobDetails(event.jobId);
      final localTs = await _loadLocalTimestamps(updatedJob.id);
      emit(
        state.copyWith(
          job: updatedJob,
          isUpdatingStatus: false,
          statusTimestamps: localTs,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isUpdatingStatus: false, errorMessage: e.toString()));
    }
  }

  JobDetailsBloc(this._repository) : super(const JobDetailsState()) {
    on<LoadJobDetails>(_onLoadJobDetails);
    on<ChangeTab>(_onChangeTab);
    on<UpdateStatus>(_onUpdateStatus);
    on<MarkArrivedAtHq>(_onMarkArrivedAtHq);
    on<ToggleSection>(_onToggleSection);
    on<ToggleMap>(_onToggleMap);
    on<UploadJobFiles>(_onUploadJobFiles);
    on<FetchJobFiles>(_onFetchJobFiles);
    on<ToggleJobClock>(_onToggleJobClock);
    on<ToggleInventoryItem>(_onToggleInventoryItem);
    on<TogglePackingItem>(_onTogglePackingItem);
  }

  void _onToggleMap(ToggleMap event, Emitter<JobDetailsState> emit) {
    emit(state.copyWith(showMap: !state.showMap));
  }

  void _onLoadJobDetails(
    LoadJobDetails event,
    Emitter<JobDetailsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final job = await _repository.getJobDetails(event.jobId);
      final localTs = await _loadLocalTimestamps(job.id);

      final pIdxStr = await _storage.read(key: _pickupIdxKey(job.id));
      final dIdxStr = await _storage.read(key: _deliveryIdxKey(job.id));
      final invStr = await _storage.read(key: _invKey(job.id));
      final packStr = await _storage.read(key: _packKey(job.id));

      final checkedInv = invStr != null && invStr.isNotEmpty
          ? invStr.split(',').toSet()
          : <String>{};
      final checkedPack = packStr != null && packStr.isNotEmpty
          ? packStr.split(',').toSet()
          : <String>{};

      emit(
        state.copyWith(
          isLoading: false,
          job: job,
          statusTimestamps: localTs,
          currentPickupIndex: int.tryParse(pIdxStr ?? '0') ?? 0,
          currentDeliveryIndex: int.tryParse(dIdxStr ?? '0') ?? 0,
          checkedInventoryKeys: checkedInv,
          checkedPackingKeys: checkedPack,
        ),
      );

      // Asynchronously calculate distance if it's currently placeholder or 0
      if (job.distance == '0.0 miles' || job.distance == 'N/A') {
        final startAddr = job.pickups.isNotEmpty
            ? job.pickups.first.fullAddress
            : '';
        final destAddr = job.deliveries.isNotEmpty
            ? job.deliveries.last.fullAddress
            : '';

        if (startAddr.isNotEmpty && destAddr.isNotEmpty) {
          final startCoord = await _mapService.getCoordinates(startAddr);
          final destCoord = await _mapService.getCoordinates(destAddr);
          if (startCoord != null && destCoord != null) {
            final routeData = await _mapService.getRoute(
              startCoord,
              destCoord,
            );
            if (routeData != null) {
              final distMeters = routeData['distance'] as int;
              final distMiles = distMeters * 0.000621371;
              final updatedJob = job.copyWith(
                distance: '${distMiles.toStringAsFixed(1)} miles',
              );
              emit(state.copyWith(job: updatedJob));
            }
          }
        }
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onChangeTab(ChangeTab event, Emitter<JobDetailsState> emit) {
    emit(state.copyWith(activeTab: event.tab));
  }

  void _onUpdateStatus(
    UpdateStatus event,
    Emitter<JobDetailsState> emit,
  ) async {
    if (state.job != null) {
      emit(state.copyWith(isUpdatingStatus: true));
      try {
        await _repository.updateJobWorkflowStatus(
          state.job!.id,
          event.newStatus,
          etaMinutes: event.etaMinutes,
          skipContractCheck: event.skipContractCheck,
        );

        if (event.newStatus != 'En route' && event.newStatus != 'Completed') {
          await _storage.write(
            key: _tsKey(state.job!.id, event.newStatus),
            value: DateTime.now().toIso8601String(),
          );
        }

        // Local index tracking for multi-stop workaround
        int nextP = state.currentPickupIndex;
        int nextD = state.currentDeliveryIndex;

        if (event.newStatus == 'Loading') {
          nextP++;
          await _storage.write(
            key: _pickupIdxKey(state.job!.id),
            value: nextP.toString(),
          );
        } else if (event.newStatus == 'Unload') {
          nextD++;
          await _storage.write(
            key: _deliveryIdxKey(state.job!.id),
            value: nextD.toString(),
          );
        } else if (event.newStatus == 'Completed') {
          // Reset when job is finished
          nextP = 0;
          nextD = 0;
          await _storage.delete(key: _pickupIdxKey(state.job!.id));
          await _storage.delete(key: _deliveryIdxKey(state.job!.id));
        }

        // Optimistically update UI or re-fetch
        final updatedJob = await _repository.getJobDetails(state.job!.id);
        final localTs = await _loadLocalTimestamps(updatedJob.id);
        emit(
          state.copyWith(
            job: updatedJob,
            isUpdatingStatus: false,
            statusTimestamps: localTs,
            currentPickupIndex: nextP,
            currentDeliveryIndex: nextD,
          ),
        );
      } catch (e) {
        // Handle error
        emit(
          state.copyWith(isUpdatingStatus: false, errorMessage: e.toString()),
        );
      }
    }
  }

  void _onToggleSection(ToggleSection event, Emitter<JobDetailsState> emit) {
    final newSections = Set<String>.from(state.expandedSections);
    if (newSections.contains(event.sectionName)) {
      newSections.remove(event.sectionName);
    } else {
      newSections.add(event.sectionName);
    }
    emit(state.copyWith(expandedSections: newSections));
  }

  void _onUploadJobFiles(
    UploadJobFiles event,
    Emitter<JobDetailsState> emit,
  ) async {
    if (state.job != null) {
      emit(state.copyWith(isUpdatingStatus: true));
      try {
        await _repository.uploadJobFiles(state.job!.id, event.filePaths);
        final updatedJob = await _repository.getJobDetails(state.job!.id);
        emit(state.copyWith(job: updatedJob, isUpdatingStatus: false));
        // Re-fetch files so the photos tab refreshes immediately
        add(FetchJobFiles(state.job!.id));
      } catch (e) {
        emit(
          state.copyWith(isUpdatingStatus: false, errorMessage: e.toString()),
        );
      }
    }
  }

  Future<void> _onFetchJobFiles(
    FetchJobFiles event,
    Emitter<JobDetailsState> emit,
  ) async {
    emit(state.copyWith(isLoadingFiles: true));
    try {
      final rawFiles = await _repository.getJobFiles(event.jobId);
      final jobFiles = rawFiles.map((f) {
        final fileObj = f['file'] as Map<String, dynamic>? ?? {};
        final url = fileObj['path']?.toString() ?? '';
        final name = url.split('/').last;
        final category = f['category']?.toString() ?? 'crew';
        final createdAt = f['createdAt'] != null
            ? DateTime.tryParse(f['createdAt'].toString())
            : null;
        return JobFile(
          id: f['id']?.toString() ?? '',
          url: url,
          name: name,
          category: category,
          uploadedAt: createdAt,
        );
      }).toList();
      emit(state.copyWith(isLoadingFiles: false, jobFiles: jobFiles));
    } catch (e) {
      emit(state.copyWith(isLoadingFiles: false));
    }
  }

  Future<void> _onToggleJobClock(
    ToggleJobClock event,
    Emitter<JobDetailsState> emit,
  ) async {
    emit(state.copyWith(isTogglingClock: true, errorMessage: null));
    try {
      await _repository.updateClockStatus(event.crewAssignmentId, event.action);
      final updatedJob = await _repository.getJobDetails(event.jobId);
      final localTs = await _loadLocalTimestamps(updatedJob.id);
      emit(
        state.copyWith(
          job: updatedJob,
          isTogglingClock: false,
          statusTimestamps: localTs,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isTogglingClock: false, errorMessage: e.toString()));
    }
  }
  Future<void> _onToggleInventoryItem(
    ToggleInventoryItem event,
    Emitter<JobDetailsState> emit,
  ) async {
    final newChecked = Set<String>.from(state.checkedInventoryKeys);
    if (newChecked.contains(event.itemKey)) {
      newChecked.remove(event.itemKey);
    } else {
      newChecked.add(event.itemKey);
    }

    emit(state.copyWith(checkedInventoryKeys: newChecked));
    await _storage.write(
      key: _invKey(event.jobId),
      value: newChecked.join(','),
    );
  }

  Future<void> _onTogglePackingItem(
    TogglePackingItem event,
    Emitter<JobDetailsState> emit,
  ) async {
    final newChecked = Set<String>.from(state.checkedPackingKeys);
    if (newChecked.contains(event.itemKey)) {
      newChecked.remove(event.itemKey);
    } else {
      newChecked.add(event.itemKey);
    }

    emit(state.copyWith(checkedPackingKeys: newChecked));
    await _storage.write(
      key: _packKey(event.jobId),
      value: newChecked.join(','),
    );
  }
}
