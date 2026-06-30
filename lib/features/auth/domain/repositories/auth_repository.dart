import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> loginWithEmailPassword(String email, String password);
  Future<Either<Failure, UserEntity>> registerWithEmailPassword(String name, String email, String password);
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, UserEntity>> saveUserRole(String uid, String role);
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, void>> logout();
}
