class ProfileEntity {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? homePhone;
  final String? address;
  final String? unitNumber;
  final bool twoFactorEnabled;
  final String? role;
  final String? photoUrl;

  ProfileEntity({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.homePhone,
    this.address,
    this.unitNumber,
    this.twoFactorEnabled = false,
    this.role,
    this.photoUrl,
  });

  ProfileEntity copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? homePhone,
    String? address,
    String? unitNumber,
    bool? twoFactorEnabled,
    String? photoUrl,
  }) {
    return ProfileEntity(
      id: id,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      homePhone: homePhone ?? this.homePhone,
      address: address ?? this.address,
      unitNumber: unitNumber ?? this.unitNumber,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      role: role ?? role,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
