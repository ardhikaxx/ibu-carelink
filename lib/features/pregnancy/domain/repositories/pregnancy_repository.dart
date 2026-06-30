import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/pregnancy_entity.dart';
import '../entities/symptom_log_entity.dart';

abstract class PregnancyRepository {
  Future<Either<Failure, PregnancyEntity?>> getActivePregnancy(String userId);
  Future<Either<Failure, PregnancyEntity>> createPregnancy(String userId, DateTime hpht, double preWeight);
  Future<Either<Failure, SymptomLogEntity>> logSymptom(SymptomLogEntity log);
  Future<Either<Failure, List<SymptomLogEntity>>> getSymptomLogs(String userId, String pregnancyId);
}
