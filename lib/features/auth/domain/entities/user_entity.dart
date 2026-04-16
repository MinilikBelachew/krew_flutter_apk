class UserEntity {
  final String id;
  final String email;
  final String? role;
  final String? tenantId;

  UserEntity({required this.id, required this.email, this.role, this.tenantId});
}
