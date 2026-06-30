import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> loginWithEmailPassword(String email, String password) async {
    try {
      final userModel = await remoteDataSource.loginWithEmailPassword(email, password);
      await localDataSource.cacheUser(userModel);
      return Right(userModel);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerWithEmailPassword(String name, String email, String password) async {
    try {
      final userModel = await remoteDataSource.registerWithEmailPassword(name, email, password);
      await localDataSource.cacheUser(userModel);
      return Right(userModel);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final userModel = await remoteDataSource.signInWithGoogle();
      await localDataSource.cacheUser(userModel);
      return Right(userModel);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> saveUserRole(String uid, String role) async {
    try {
      final userModel = await remoteDataSource.saveUserRole(uid, role);
      await localDataSource.cacheUser(userModel);
      return Right(userModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        // Coba sinkronisasi dari Firebase secara offline-first
        remoteDataSource.getCurrentUser().then((remoteUser) {
          if (remoteUser != null) {
            localDataSource.cacheUser(remoteUser);
          }
        }).catchError((_) {});
        return Right(cachedUser);
      }
      final remoteUser = await remoteDataSource.getCurrentUser();
      if (remoteUser != null) {
        await localDataSource.cacheUser(remoteUser);
      }
      return Right(remoteUser);
    } catch (e) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
