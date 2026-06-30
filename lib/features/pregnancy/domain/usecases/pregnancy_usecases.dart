import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/pregnancy_entity.dart';
import '../entities/symptom_log_entity.dart';
import '../repositories/pregnancy_repository.dart';

class GetActivePregnancyParams {
  final String userId;
  GetActivePregnancyParams(this.userId);
}

class GetActivePregnancyUseCase implements UseCase<PregnancyEntity?, GetActivePregnancyParams> {
  final PregnancyRepository repository;
  GetActivePregnancyUseCase(this.repository);

  @override
  Future<Either<Failure, PregnancyEntity?>> call(GetActivePregnancyParams params) {
    return repository.getActivePregnancy(params.userId);
  }
}

class CreatePregnancyParams {
  final String userId;
  final DateTime hpht;
  final double prePregnancyWeight;
  CreatePregnancyParams({required this.userId, required this.hpht, required this.prePregnancyWeight});
}

class CreatePregnancyUseCase implements UseCase<PregnancyEntity, CreatePregnancyParams> {
  final PregnancyRepository repository;
  CreatePregnancyUseCase(this.repository);

  @override
  Future<Either<Failure, PregnancyEntity>> call(CreatePregnancyParams params) {
    return repository.createPregnancy(params.userId, params.hpht, params.prePregnancyWeight);
  }
}

class LogSymptomUseCase implements UseCase<SymptomLogEntity, SymptomLogEntity> {
  final PregnancyRepository repository;
  LogSymptomUseCase(this.repository);

  @override
  Future<Either<Failure, SymptomLogEntity>> call(SymptomLogEntity params) {
    return repository.logSymptom(params);
  }
}

class GetSymptomLogsParams {
  final String userId;
  final String pregnancyId;
  GetSymptomLogsParams({required this.userId, required this.pregnancyId});
}

class GetSymptomLogsUseCase implements UseCase<List<SymptomLogEntity>, GetSymptomLogsParams> {
  final PregnancyRepository repository;
  GetSymptomLogsUseCase(this.repository);

  @override
  Future<Either<Failure, List<SymptomLogEntity>>> call(GetSymptomLogsParams params) {
    return repository.getSymptomLogs(params.userId, params.pregnancyId);
  }
}
