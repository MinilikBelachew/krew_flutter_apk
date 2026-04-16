import 'package:equatable/equatable.dart';

class CrewMemberEntity extends Equatable {
  final int id;
  final String role;
  final String status;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String? photoUrl;

  const CrewMemberEntity({
    required this.id,
    required this.role,
    required this.status,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [
    photoUrl,
  ];

  CrewMemberEntity copyWith({
    int? id,
    String? role,
    String? status,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? photoUrl,
  }) {
    return CrewMemberEntity(
      id: id ?? this.id,
      role: role ?? this.role,
      status: status ?? this.status,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

class JobEntity extends Equatable {
  final String id;
  final String rawId; // Added for backend ID navigation
  final int crewAssignmentId; // Added for confirmation
  final String customerName;
  final String pickupAddress;
  final String dropoffAddress;
  final String weight;
  final String truckNumber;
  final String status; // e.g., 'SCHEDULED', 'COMPLETED' (Job workflow status)
  final String
  crewStatus; // e.g., 'Pending', 'Confirmed' (Employee assignment status)
  final DateTime scheduledDate;
  final int crewCount;
  final List<String> crewAvatars;
  final List<CrewMemberEntity> crewMembers;
  final String? currentEmployeeDuration;
  final DateTime? currentEmployeeClockIn;

  const JobEntity({
    required this.id,
    required this.rawId,
    required this.crewAssignmentId,
    required this.customerName,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.weight,
    required this.truckNumber,
    required this.status,
    required this.crewStatus,
    required this.scheduledDate,
    required this.crewCount,
    required this.crewAvatars,
    required this.crewMembers,
    this.currentEmployeeDuration,
    this.currentEmployeeClockIn,
  });

  @override
  List<Object?> get props => [
    crewMembers,
  ];

  JobEntity copyWith({
    String? id,
    String? rawId,
    int? crewAssignmentId,
    String? customerName,
    String? pickupAddress,
    String? dropoffAddress,
    String? weight,
    String? truckNumber,
    String? status,
    String? crewStatus,
    DateTime? scheduledDate,
    int? crewCount,
    List<String>? crewAvatars,
    List<CrewMemberEntity>? crewMembers,
    String? currentEmployeeDuration,
    DateTime? currentEmployeeClockIn,
  }) {
    return JobEntity(
      id: id ?? this.id,
      rawId: rawId ?? this.rawId,
      crewAssignmentId: crewAssignmentId ?? this.crewAssignmentId,
      customerName: customerName ?? this.customerName,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      weight: weight ?? this.weight,
      truckNumber: truckNumber ?? this.truckNumber,
      status: status ?? this.status,
      crewStatus: crewStatus ?? this.crewStatus,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      crewCount: crewCount ?? this.crewCount,
      crewAvatars: crewAvatars ?? this.crewAvatars,
      crewMembers: crewMembers ?? this.crewMembers,
      currentEmployeeDuration: currentEmployeeDuration ?? this.currentEmployeeDuration,
      currentEmployeeClockIn: currentEmployeeClockIn ?? this.currentEmployeeClockIn,
    );
  }
}
