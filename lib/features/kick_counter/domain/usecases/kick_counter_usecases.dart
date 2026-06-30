import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/kick_session_entity.dart';
import '../repositories/kick_counter_repository.dart';

class SaveKickSessionParams {
  final KickSessionEntity session;
  final String userId;
  SaveKickSessionParams({required this.session, required this.userId});
}

class SaveKickSessionUseCase implements UseCase<KickSessionEntity, SaveKickSessionParams> {
  final KickCounterRepository repository;
  SaveKickSessionUseCase(this.repository);

  @override
  Future<Either<Failure, KickSessionEntity>> call(SaveKickSessionParams params) {
    return repository.saveSession(params.session, params.userId);
  }
}

class GetKickSessionsParams {
  final String userId;
  final String pregnancyId;
  GetKickSessionsParams({required this.userId, required this.pregnancyId});
}

class GetKickSessionsUseCase implements UseCase<List<KickSessionEntity>, GetKickSessionsParams> {
  final KickCounterRepository repository;
  GetKickSessionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<KickSessionEntity>>> call(GetKickSessionsParams params) {
    return repository.getSessions(params.userId, params.pregnancyId);
  }
}
