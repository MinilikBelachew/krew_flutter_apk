import 'package:movers/features/home/domain/entities/job_entity.dart';

class JobModel extends JobEntity {
  const JobModel({
    required super.id,
    required super.rawId,
    required super.crewAssignmentId,
    required super.customerName,
    required super.pickupAddress,
    required super.dropoffAddress,
    required super.weight,
    required super.truckNumber,
    required super.status,
    required super.crewStatus,
    required super.scheduledDate,
    required super.crewCount,
    required super.crewAvatars,
    required super.crewMembers,
    super.currentEmployeeDuration,
    super.currentEmployeeClockIn,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    // The structure can be nested under 'job' if coming from getMyJobs
    final Map<String, dynamic> jobData = json['job'] ?? json;
    final Map<String, dynamic>? lead = jobData['lead'];

    final firstName = lead?['customerFirstName']?.toString() ?? '';
    final lastName = lead?['customerLastName']?.toString() ?? '';
    final customerName = ('$firstName $lastName').trim().isNotEmpty
        ? ('$firstName $lastName').trim()
        : (lead?['clientName']?.toString() ?? 'Customer');

    // Parse addresses
    String pickup = 'TBD';
    String delivery = 'TBD';
    if (lead != null && lead['addresses'] != null) {
      final List addresses = lead['addresses'];
      for (var addr in addresses) {
        if (addr['addressType']?.toString().toLowerCase() == 'pickup') {
          pickup = addr['addressLine1'] ?? 'TBD';
        } else if (addr['addressType']?.toString().toLowerCase() ==
            'delivery') {
          delivery = addr['addressLine1'] ?? 'TBD';
        }
      }
    }

    // Parse weight
    String weightStr = 'TBD';
    if (lead != null && lead['moveSize'] != null) {
      weightStr = '${lead['moveSize']['weight'] ?? 'TBD'} lbs';
    }

    // Parse truck number
    String truckStr = 'TBD';
    if (jobData['vehicles'] != null &&
        (jobData['vehicles'] as List).isNotEmpty) {
      final firstVehicleList = jobData['vehicles'] as List;
      if (firstVehicleList.isNotEmpty) {
        final firstVehicle = firstVehicleList[0]['vehicle'];
        if (firstVehicle != null) {
          truckStr =
              firstVehicle['name']?.toString() ??
              firstVehicle['plate']?.toString() ??
              'TBD';
        }
      }
    }

    // Parse crew
    int cCount = 1; // Default to 1 (the current user) if empty
    List<String> avatars = [];
    List<CrewMemberEntity> parsedCrewMembers = [];

    if (jobData['crewMembers'] != null) {
      final List crewList = jobData['crewMembers'];
      cCount = crewList.isNotEmpty ? crewList.length : 1;
      for (var crew in crewList) {
        final employee = crew['employee'];
        if (employee != null) {
          final photoUrl = employee['user']?['photo']?['path'];
          if (photoUrl != null && photoUrl.toString().isNotEmpty) {
            avatars.add(photoUrl.toString());
          }

          parsedCrewMembers.add(
            CrewMemberEntity(
              id: employee['id'] ?? 0,
              role: crew['role']?.toString() ?? 'Mover',
              status: crew['status']?.toString() ?? 'Pending',
              firstName: employee['firstName']?.toString() ?? 'Unknown',
              lastName: employee['lastName']?.toString() ?? '',
              phone: employee['phone']?.toString() ?? 'N/A',
              email: employee['email']?.toString(),
              photoUrl: photoUrl?.toString(),
            ),
          );
        }
      }
    }

    return JobModel(
      id: '#${lead?['orderNumber'] ?? jobData['id']}',
      rawId: jobData['id'].toString(),
      crewAssignmentId: (json['crewAssignmentId'] ?? json['id'] ?? 0) as int,
      customerName: customerName,
      pickupAddress: pickup,
      dropoffAddress: delivery,
      weight: weightStr,
      truckNumber: truckStr,
      status: jobData['status']?.toString().toUpperCase() ?? 'SCHEDULED',
      crewStatus: (json['status']?.toString() ?? 'PENDING')
          .trim()
          .toUpperCase(),
      scheduledDate: jobData['scheduledDate'] != null
          ? DateTime.parse(jobData['scheduledDate'])
          : DateTime.now(),
      crewCount: cCount,
      crewAvatars: avatars,
      crewMembers: parsedCrewMembers,
      currentEmployeeDuration: json['duration']?.toString(), // This works if json is the crew assignment root
      currentEmployeeClockIn: json['clockIn'] != null ? DateTime.parse(json['clockIn']) : null,
    );
  }
}
