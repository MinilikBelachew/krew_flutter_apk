import 'package:flutter/material.dart';
import '../../domain/entities/job_detail_entity.dart';

class JobDetailsModel extends JobDetailEntity {
  const JobDetailsModel({
    required super.id,
    required super.displayId,
    required super.clientName,
    required super.phoneNumber,
    required super.email,
    super.leadTags = const [],
    super.statusEvents = const [],
    required super.pickups,
    required super.deliveries,
    required super.distance,
    required super.weight,
    required super.truckNumber,
    required super.rate,
    required super.crewCount,
    required super.truckCount,
    required super.timeEstimate,
    required super.scheduledDate,
    super.startTime,
    super.endTime,
    super.ballparkCrewSize,
    super.ballparkLaborHours,
    super.ballparkVolume,
    super.ballparkTravelDuration,
    super.clockIn,
    super.clockOut,
    super.isClockedIn,
    super.duration,
    super.arrivedAtHqAt,
    super.notes = const [],
    super.materials = const [],
    super.inventoryItems = const [],
    super.crewMembers = const [],
    super.files = const [],
    super.crewStatus = 'PENDING',
    required super.currentStatus,
    super.moveSizeName,
    super.moveSizeCubicFt,
    super.moveSizeWeight,
    super.isContractSigned = false,
  });

  factory JobDetailsModel.fromJson(Map<String, dynamic> json) {
    final lead = json['lead'] as Map<String, dynamic>? ?? {};
    final addresses = (lead['addresses'] as List? ?? []);

    final statusEventsJson = (json['statusEvents'] as List? ?? []);
    final statusEvents = statusEventsJson
        .whereType<Map>()
        .map((e) {
          return StatusEvent(
            status: e['status']?.toString() ?? '',
            createdAt:
                DateTime.tryParse(e['createdAt']?.toString() ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0),
          );
        })
        .where((e) => e.status.isNotEmpty)
        .toList();

    final tagsJson = (lead['tags'] as List? ?? []);
    final leadTags = tagsJson
        .map((t) {
          if (t is Map) {
            final tag = t['tag'];
            if (tag is Map) {
              return tag['name']?.toString() ?? '';
            }
          }
          return '';
        })
        .where((n) => n.isNotEmpty)
        .toList();

    final ballparkQuote = lead['ballparkQuote'] as Map<String, dynamic>?;
    final ballparkDetails = ballparkQuote?['details'] as Map<String, dynamic>?;

    final pickups = addresses
        .where((a) => a['addressType'] == 'pickup')
        .toList()
        .asMap()
        .entries
        .map((entry) {
          final idx = entry.key;
          final a = entry.value;
          return AddressDetail(
            id: a['id']?.toString() ?? '',
            addressLine1: a['addressLine1'] ?? '',
            city: a['city'],
            state: a['state'],
            zipCode: a['zipCode'],
            label: 'P${idx + 1}',
          );
        })
        .toList();

    final deliveries = addresses
        .where((a) => a['addressType'] == 'delivery')
        .toList()
        .asMap()
        .entries
        .map((entry) {
          final idx = entry.key;
          final a = entry.value;
          return AddressDetail(
            id: a['id']?.toString() ?? '',
            addressLine1: a['addressLine1'] ?? '',
            city: a['city'],
            state: a['state'],
            zipCode: a['zipCode'],
            label: 'D${idx + 1}',
          );
        })
        .toList();

    final inventoryItems = (lead['inventoryItems'] as List? ?? []).map((item) {
      final catalogItem = item['catalogItem'] as Map<String, dynamic>?;
      final isNg = item['isNg'] as bool? ?? false;
      final quantity = (item['quantity'] as num?)?.toInt() ?? 1;

      final n =
          item['customItemName'] ??
          catalogItem?['itemName']?.toString() ??
          'Unknown Item';

      return InventoryItem(
        name: n,
        room: item['room']?['roomName']?.toString() ?? 'General',
        truckCount: isNg ? 0 : quantity,
        houseCount: isNg ? quantity : 0,
        icon: _getIconForName(n),
        isPackingNeeded: item['isPackingNeeded'] as bool? ?? false,
        isPbo: item['isPbo'] as bool? ?? false,
        isNg: isNg,
        isOversize: catalogItem?['isOversize'] as bool? ?? false,
        imageUrl: catalogItem?['imageUrl'],
      );
    }).toList();

    final packingJson = (lead['packing']?['items'] as List? ?? []);
    final materials = packingJson.map((item) {
      final mat = item['packingMaterial'] as Map<String, dynamic>? ?? {};
      return MaterialDetail(
        name:
            item['itemName']?.toString() ??
            mat['materialName']?.toString() ??
            'Unknown Material',
        count:
            (item['packingQuantity'] as num?)?.toInt() ??
            (item['containerQuantity'] as num?)?.toInt() ??
            0,
      );
    }).toList();

    final notesJson = (lead['notes'] as List? ?? []);
    final notes = notesJson
        .map((n) => n['content']?.toString() ?? n['noteText']?.toString() ?? '')
        .where((n) => n.isNotEmpty)
        .toList();

    final crewMembersJson = (json['crewMembers'] as List? ?? []);
    final crewMembers = crewMembersJson.map((cm) {
      final employee = cm['employee'] as Map<String, dynamic>? ?? {};
      final user = employee['user'] as Map<String, dynamic>? ?? {};
      final position = employee['position'] as Map<String, dynamic>? ?? {};
      final photo = user['photo'] as Map<String, dynamic>? ?? {};

      return CrewMember(
        assignmentId: cm['id']?.toString() ?? '',
        userId: user['id']?.toString() ?? '',
        name: '${employee['firstName'] ?? ''} ${employee['lastName'] ?? ''}'
            .trim(),
        role: position['name'] ?? 'Crew',
        status: cm['status']?.toString() ?? 'Pending',
        photoUrl: photo['path']?.toString() ?? photo['url']?.toString(),
        clockInTime: cm['clockIn'] != null
            ? DateTime.parse(cm['clockIn'])
            : null,
        clockOutTime: cm['clockOut'] != null
            ? DateTime.parse(cm['clockOut'])
            : null,
        duration: cm['duration']?.toString(),
      );
    }).toList();

    final filesJson = (lead['files'] as List? ?? []);
    final files = filesJson.map((f) {
      return JobFile(
        id: f['id']?.toString() ?? '',
        url: f['path']?.toString() ?? '',
        name:
            f['fileName']?.toString() ??
            f['path']?.toString().split('/').last ??
            'File',
        category: f['category']?.toString() ?? 'general',
        uploadedAt: f['createdAt'] != null
            ? DateTime.tryParse(f['createdAt'].toString())
            : null,
      );
    }).toList();

    final backendStatus = json['status']?.toString() ?? 'Scheduled';
    final reverseStatusMap = {
      'Scheduled': 'Scheduled',
      'EN_ROUTE_TO_PICKUP': 'En route',
      'AT_PICKUP': 'Arrived',
      'LOADING': 'Loading',
      'EN_ROUTE_TO_DELIVERY': 'Loaded',
      'AT_DELIVERY': 'Delivery',
      'UNLOADING': 'Unload',
      'COMPLETED': 'Completed',
    };

    final totalWeight = _toNum(lead['totalWeight']);
    final estimatedTotal = _toNum(lead['estimatedTotal']);
    final estimatedHours = _toNum(lead['estimatedHours']);
    final laborHours = _toNum(ballparkDetails?['laborHours']);

    final displayId = '#${lead['orderNumber'] ?? json['id']}';

    return JobDetailsModel(
      id: json['id'].toString(),
      displayId: displayId,
      clientName:
          '${lead['customerFirstName'] ?? ''} ${lead['customerLastName'] ?? ''}'
              .trim(),
      phoneNumber: lead['customerPhonePrimary'] ?? '',
      email: lead['customerEmail'] ?? '',
      leadTags: leadTags,
      statusEvents: statusEvents,
      pickups: pickups,
      deliveries: deliveries,
      distance: (lead['distance'] != null)
          ? '${(lead['distance'] as num).toStringAsFixed(1)} miles'
          : '0.0 miles',
      weight: '${(totalWeight ?? 0).toStringAsFixed(0)} lbs',
      truckNumber: (json['vehicles'] as List?)?.isNotEmpty == true
          ? (json['vehicles'][0]['vehicle']?['name']?.toString() ?? 'N/A')
          : 'N/A',
      rate: estimatedTotal != null
          ? '\$${estimatedTotal.toStringAsFixed(2)}'
          : '\$0',
      crewCount: (json['crewMembers'] as List?)?.isNotEmpty == true
          ? (json['crewMembers'] as List).length
          : (lead['estimatedCrewSize'] as num?)?.toInt() ?? 0,
      truckCount: (json['vehicles'] as List?)?.isNotEmpty == true
          ? (json['vehicles'] as List).length
          : (lead['estimatedTruckCount'] as num?)?.toInt() ?? 0,
      timeEstimate: estimatedHours != null
          ? '${estimatedHours.toStringAsFixed(2)}h'
          : '0h 0m',
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'])
          : DateTime.now(),
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
      ballparkCrewSize: (ballparkDetails?['crewSize'] as num?)?.toInt(),
      ballparkLaborHours: laborHours?.toDouble(),
      ballparkVolume: (ballparkDetails?['volume'] as num?)?.toInt(),
      ballparkTravelDuration: ballparkDetails?['travelDuration']?.toString(),
      clockIn: json['clockIn'] != null
          ? DateTime.tryParse(json['clockIn'].toString())
          : null,
      clockOut: json['clockOut'] != null
          ? DateTime.tryParse(json['clockOut'].toString())
          : null,
      isClockedIn: json['isClockedIn'] as bool?,
      duration: json['duration']?.toString(),
      arrivedAtHqAt: json['arrivedAtHqAt'] != null
          ? DateTime.tryParse(json['arrivedAtHqAt'].toString())
          : null,
      notes: notes,
      materials: materials,
      inventoryItems: inventoryItems,
      crewMembers: crewMembers,
      files: files,
      crewStatus: json['status']?.toString().toUpperCase() ?? 'PENDING',
      currentStatus: reverseStatusMap[backendStatus] ?? backendStatus,
      moveSizeName: lead['moveSize']?['name']?.toString(),
      moveSizeCubicFt: lead['moveSize']?['cubicFt']?.toString(),
      moveSizeWeight: lead['moveSize']?['weight']?.toString(),
      isContractSigned: json['isContractSigned'] as bool? ?? false,
    );
  }

  @override
  JobDetailsModel copyWith({
    DateTime? arrivedAtHqAt,
    String? id,
    String? displayId,
    String? clientName,
    String? phoneNumber,
    String? email,
    List<String>? leadTags,
    List<StatusEvent>? statusEvents,
    List<AddressDetail>? pickups,
    List<AddressDetail>? deliveries,
    String? distance,
    String? weight,
    String? truckNumber,
    String? rate,
    int? crewCount,
    int? truckCount,
    String? timeEstimate,
    DateTime? scheduledDate,
    String? startTime,
    String? endTime,
    int? ballparkCrewSize,
    double? ballparkLaborHours,
    int? ballparkVolume,
    String? ballparkTravelDuration,
    DateTime? clockIn,
    DateTime? clockOut,
    bool? isClockedIn,
    String? duration,
    List<String>? notes,
    List<MaterialDetail>? materials,
    List<InventoryItem>? inventoryItems,
    List<CrewMember>? crewMembers,
    List<JobFile>? files,
    String? crewStatus,
    String? currentStatus,
    String? moveSizeName,
    String? moveSizeCubicFt,
    String? moveSizeWeight,
    bool? isContractSigned,
  }) {
    return JobDetailsModel(
      arrivedAtHqAt: arrivedAtHqAt ?? this.arrivedAtHqAt,
      id: id ?? this.id,
      displayId: displayId ?? this.displayId,
      clientName: clientName ?? this.clientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      leadTags: leadTags ?? this.leadTags,
      statusEvents: statusEvents ?? this.statusEvents,
      pickups: pickups ?? this.pickups,
      deliveries: deliveries ?? this.deliveries,
      distance: distance ?? this.distance,
      weight: weight ?? this.weight,
      truckNumber: truckNumber ?? this.truckNumber,
      rate: rate ?? this.rate,
      crewCount: crewCount ?? this.crewCount,
      truckCount: truckCount ?? this.truckCount,
      timeEstimate: timeEstimate ?? this.timeEstimate,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      ballparkCrewSize: ballparkCrewSize ?? this.ballparkCrewSize,
      ballparkLaborHours: ballparkLaborHours ?? this.ballparkLaborHours,
      ballparkVolume: ballparkVolume ?? this.ballparkVolume,
      ballparkTravelDuration:
          ballparkTravelDuration ?? this.ballparkTravelDuration,
      clockIn: clockIn ?? this.clockIn,
      clockOut: clockOut ?? this.clockOut,
      isClockedIn: isClockedIn ?? this.isClockedIn,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      materials: materials ?? this.materials,
      inventoryItems: inventoryItems ?? this.inventoryItems,
      crewMembers: crewMembers ?? this.crewMembers,
      files: files ?? this.files,
      crewStatus: crewStatus ?? this.crewStatus,
      currentStatus: currentStatus ?? this.currentStatus,
      moveSizeName: moveSizeName ?? this.moveSizeName,
      moveSizeCubicFt: moveSizeCubicFt ?? this.moveSizeCubicFt,
      moveSizeWeight: moveSizeWeight ?? this.moveSizeWeight,
      isContractSigned: isContractSigned ?? this.isContractSigned,
    );
  }

  static IconData _getIconForName(String name) {
    final n = name.toLowerCase();
    if (n.contains('bed') || n.contains('mattress')) return Icons.bed_outlined;
    if (n.contains('chair') || n.contains('stool')) return Icons.chair_outlined;
    if (n.contains('table') || n.contains('desk')) {
      return Icons.table_restaurant_outlined;
    }
    if (n.contains('sofa') || n.contains('couch')) {
      return Icons.weekend_outlined;
    }
    if (n.contains('tv') || n.contains('television')) return Icons.tv_outlined;
    if (n.contains('box')) return Icons.inventory_2_outlined;
    if (n.contains('lamp')) return Icons.lightbulb_outline;
    if (n.contains('fridge') || n.contains('refrigerator')) {
      return Icons.kitchen_outlined;
    }
    return Icons.inventory_2_outlined;
  }

  static num? _toNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    if (value is Map) {
      final d = value['d'];
      if (d is List && d.isNotEmpty) {
        final first = d.first;
        if (first is num) return first;
        if (first is String) return num.tryParse(first);
      }
    }
    return null;
  }
}
