import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;
  LoginParams({required this.email, required this.password});
}

class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) {
    return repository.loginWithEmailPassword(params.email, params.password);
  }
}

class RegisterParams {
  final String name;
  final String email;
  final String password;
  RegisterParams({required this.name, required this.email, required this.password});
}

class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) {
    return repository.registerWithEmailPassword(params.name, params.email, params.password);
  }
}

class GoogleLoginUseCase implements UseCase<UserEntity, NoParams> {
  final AuthRepository repository;
  GoogleLoginUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) {
    return repository.signInWithGoogle();
  }
}

class SaveRoleParams {
  final String uid;
  final String role;
  SaveRoleParams({required this.uid, required this.role});
}

class SaveUserRoleUseCase implements UseCase<UserEntity, SaveRoleParams> {
  final AuthRepository repository;
  SaveUserRoleUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SaveRoleParams params) {
    return repository.saveUserRole(params.uid, params.role);
  }
}

class GetCurrentUserUseCase implements UseCase<UserEntity?, NoParams> {
  final AuthRepository repository;
  GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) {
    return repository.getCurrentUser();
  }
}

class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.logout();
  }
}
