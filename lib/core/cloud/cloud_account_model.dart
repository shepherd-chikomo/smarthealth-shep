/// Cloud-safe patient account cached locally (no clinical PHI).
class CloudAccount {
  const CloudAccount({
    required this.accountUuid,
    required this.smarthealthPatientId,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.avatarPath,
    required this.updatedAt,
  });

  final String accountUuid;
  final String smarthealthPatientId;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final String? dateOfBirth;
  final String? gender;
  final String? avatarPath;
  final DateTime updatedAt;

  String? get displayName {
    final parts = [
      if (firstName != null && firstName!.isNotEmpty) firstName,
      if (lastName != null && lastName!.isNotEmpty) lastName,
    ];
    if (parts.isEmpty) return null;
    return parts.join(' ');
  }

  Map<String, dynamic> toJson() => {
        'accountUuid': accountUuid,
        'smarthealthPatientId': smarthealthPatientId,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'email': email,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'avatarPath': avatarPath,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory CloudAccount.fromJson(Map<String, dynamic> json) {
    return CloudAccount(
      accountUuid: json['accountUuid'] as String,
      smarthealthPatientId: json['smarthealthPatientId'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      avatarPath: json['avatarPath'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
