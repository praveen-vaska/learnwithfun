import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String? phone; // 10 digits starting with 6,7,8,9
  final String passwordHash;
  final DateTime createdAt;
  final String avatarAsset;

  const AppUser({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.passwordHash,
    required this.createdAt,
    this.avatarAsset = 'assets/images/avatars/avatar_boy_1.svg',
  });

  bool get isPhoneUser => phone != null && phone!.isNotEmpty;
  bool get isEmailUser => email != null && email!.isNotEmpty;
  String? get phoneNumber => phone;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
      'avatarAsset': avatarAsset,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      passwordHash: json['passwordHash'] as String,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      avatarAsset: json['avatarAsset'] as String? ?? 'assets/images/avatars/avatar_boy_1.svg',
    );
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? passwordHash,
    DateTime? createdAt,
    String? avatarAsset,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      avatarAsset: avatarAsset ?? this.avatarAsset,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    passwordHash,
    createdAt,
    avatarAsset,
  ];
}
