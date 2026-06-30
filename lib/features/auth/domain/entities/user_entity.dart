import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String role; // 'pregnant', 'toddler_parent', 'both', or 'pending'
  final String? photoUrl;
  final DateTime? createdAt;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    this.role = 'pending',
    this.photoUrl,
    this.createdAt,
  });

  bool get isRoleSelected => role != 'pending' && role.isNotEmpty;

  @override
  List<Object?> get props => [uid, email, name, role, photoUrl, createdAt];
}
