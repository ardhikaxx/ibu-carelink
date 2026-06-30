import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/kick_session_entity.dart';

abstract class KickCounterRepository {
  Future<Either<Failure, KickSessionEntity>> saveSession(KickSessionEntity session, String userId);
  Future<Either<Failure, List<KickSessionEntity>>> getSessions(String userId, String pregnancyId);
}
