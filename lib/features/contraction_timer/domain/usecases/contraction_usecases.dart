import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/contraction_entity.dart';
import '../repositories/contraction_repository.dart';

class SaveContractionParams {
  final ContractionEntity contraction;
  final String userId;
  SaveContractionParams({required this.contraction, required this.userId});
}

class SaveContractionUseCase implements UseCase<ContractionEntity, SaveContractionParams> {
  final ContractionRepository repository;
  SaveContractionUseCase(this.repository);

  @override
  Future<Either<Failure, ContractionEntity>> call(SaveContractionParams params) {
    return repository.saveContraction(params.contraction, params.userId);
  }
}

class GetContractionsParams {
  final String userId;
  final String pregnancyId;
  GetContractionsParams({required this.userId, required this.pregnancyId});
}

class GetContractionsUseCase implements UseCase<List<ContractionEntity>, GetContractionsParams> {
  final ContractionRepository repository;
  GetContractionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ContractionEntity>>> call(GetContractionsParams params) {
    return repository.getContractions(params.userId, params.pregnancyId);
  }
}
