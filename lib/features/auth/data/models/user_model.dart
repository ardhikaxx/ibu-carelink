import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.name,
    super.role,
    super.photoUrl,
    super.createdAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> map, String docId) {
    return UserModel(
      uid: docId,
      email: map['email'] ?? '',
      name: map['name'] ?? 'Pengguna CareLink',
      role: map['role'] ?? 'pending',
      photoUrl: map['photoUrl'] ?? map['photoURL'] ?? map['picture'] ?? map['avatar'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'photoUrl': photoUrl,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      name: entity.name,
      role: entity.role,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
    );
  }
}
