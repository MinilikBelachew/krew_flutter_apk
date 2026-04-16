import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class JobDetailEntity extends Equatable {
  final String id;
  final String displayId;
  final String clientName;
  final String phoneNumber;
  final String email;
  final List<String> leadTags;
  final List<StatusEvent> statusEvents;
  final List<AddressDetail> pickups;
  final List<AddressDetail> deliveries;
  final String distance;
  final String weight;
  final String truckNumber;
  final String rate;
  final int crewCount;
  final int truckCount;
  final String timeEstimate;
  final DateTime scheduledDate;
  final String? startTime;
  final String? endTime;
  final int? ballparkCrewSize;
  final double? ballparkLaborHours;
  final int? ballparkVolume;
  final String? ballparkTravelDuration;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final bool? isClockedIn;
  final String? duration;
  final DateTime? arrivedAtHqAt;
  final List<String> notes;
  final List<MaterialDetail> materials;
  final List<InventoryItem> inventoryItems;
  final List<CrewMember> crewMembers;
  final List<JobFile> files;
  final String? currentCrewAssignmentId;
  final String crewStatus; // PENDING, CONFIRMED, etc.
  final String currentStatus; // 'En route', 'Arrived', 'Loading', etc.
  final String? moveSizeName;
  final String? moveSizeCubicFt;
  final String? moveSizeWeight;
  final bool isContractSigned;

  const JobDetailEntity({
    required this.id,
    required this.displayId,
    required this.clientName,
    required this.phoneNumber,
    required this.email,
    this.leadTags = const [],
    this.statusEvents = const [],
    required this.pickups,
    required this.deliveries,
    required this.distance,
    required this.weight,
    required this.truckNumber,
    required this.rate,
    required this.crewCount,
    required this.truckCount,
    required this.timeEstimate,
    required this.scheduledDate,
    this.startTime,
    this.endTime,
    this.ballparkCrewSize,
    this.ballparkLaborHours,
    this.ballparkVolume,
    this.ballparkTravelDuration,
    this.clockIn,
    this.clockOut,
    this.isClockedIn,
    this.duration,
    this.arrivedAtHqAt,
    this.notes = const [],
    this.materials = const [],
    this.inventoryItems = const [],
    this.crewMembers = const [],
    this.files = const [],
    this.currentCrewAssignmentId,
    this.crewStatus = 'PENDING',
    required this.currentStatus,
    this.moveSizeName,
    this.moveSizeCubicFt,
    this.moveSizeWeight,
    this.isContractSigned = false,
  });

  JobDetailEntity copyWith({
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
    DateTime? arrivedAtHqAt,
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
    return JobDetailEntity(
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
      arrivedAtHqAt: arrivedAtHqAt ?? this.arrivedAtHqAt,
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

  @override
  List<Object?> get props => [
    id,
    displayId,
    clientName,
    phoneNumber,
    email,
    leadTags,
    statusEvents,
    pickups,
    deliveries,
    distance,
    weight,
    truckNumber,
    rate,
    crewCount,
    truckCount,
    timeEstimate,
    scheduledDate,
    startTime,
    endTime,
    ballparkCrewSize,
    ballparkLaborHours,
    ballparkVolume,
    ballparkTravelDuration,
    clockIn,
    clockOut,
    isClockedIn,
    duration,
    arrivedAtHqAt,
    notes,
    materials,
    inventoryItems,
    crewMembers,
    files,
    crewStatus,
    currentStatus,
    moveSizeName,
    moveSizeCubicFt,
    moveSizeWeight,
    isContractSigned,
  ];
}

class StatusEvent extends Equatable {
  final String status;
  final DateTime createdAt;

  const StatusEvent({required this.status, required this.createdAt});

  @override
  List<Object?> get props => [status, createdAt];
}

class JobFile extends Equatable {
  final String id;
  final String url;
  final String name;
  final String category; // 'general', 'customer', 'crew', 'portal_upload'
  final DateTime? uploadedAt;

  const JobFile({
    required this.id,
    required this.url,
    required this.name,
    required this.category,
    this.uploadedAt,
  });

  @override
  List<Object?> get props => [id, url, name, category, uploadedAt];
}

class CrewMember extends Equatable {
  final String assignmentId;
  final String userId;
  final String name;
  final String role;
  final String status; // Pending, Confirmed, etc.
  final String? photoUrl;
  final DateTime? clockInTime;
  final DateTime? clockOutTime;
  final String? duration;

  const CrewMember({
    required this.assignmentId,
    required this.userId,
    required this.name,
    required this.role,
    required this.status,
    this.photoUrl,
    this.clockInTime,
    this.clockOutTime,
    this.duration,
  });

  @override
  List<Object?> get props => [
    assignmentId,
    userId,
    name,
    role,
    status,
    photoUrl,
    clockInTime,
    clockOutTime,
    duration,
  ];
}

class InventoryItem extends Equatable {
  final String name;
  final String room;
  final int truckCount;
  final int houseCount;
  final IconData icon;
  final bool isPackingNeeded;
  final bool isPbo;
  final bool isNg;
  final bool isOversize;
  final String? imageUrl;

  const InventoryItem({
    required this.name,
    required this.room,
    required this.truckCount,
    required this.houseCount,
    required this.icon,
    this.isPackingNeeded = false,
    this.isPbo = false,
    this.isNg = false,
    this.isOversize = false,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    name,
    room,
    truckCount,
    houseCount,
    icon,
    isPackingNeeded,
    isPbo,
    isNg,
    isOversize,
    imageUrl,
  ];
}

class MaterialDetail extends Equatable {
  final String name;
  final int count;

  const MaterialDetail({required this.name, required this.count});

  @override
  List<Object?> get props => [name, count];
}

class AddressDetail extends Equatable {
  final String id;
  final String addressLine1;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? label; // P1, P2, D1, D2 etc

  const AddressDetail({
    required this.id,
    required this.addressLine1,
    this.city,
    this.state,
    this.zipCode,
    this.label,
  });

  String get fullAddress {
    final parts = [addressLine1];
    if (city != null) parts.add(city!);
    if (state != null) parts.add(state!);
    if (zipCode != null) parts.add(zipCode!);
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [id, addressLine1, city, state, zipCode, label];
}
