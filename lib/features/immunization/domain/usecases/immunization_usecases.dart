import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/immunization_entity.dart';
import '../repositories/immunization_repository.dart';

class GetImmunizationsParams {
  final String userId;
  final String childId;
  GetImmunizationsParams({required this.userId, required this.childId});
}

class GetImmunizationsUseCase implements UseCase<List<ImmunizationEntity>, GetImmunizationsParams> {
  final ImmunizationRepository repository;
  GetImmunizationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ImmunizationEntity>>> call(GetImmunizationsParams params) {
    return repository.getImmunizations(params.userId, params.childId);
  }
}

class UpdateImmunizationParams {
  final ImmunizationEntity immunization;
  final String userId;
  UpdateImmunizationParams({required this.immunization, required this.userId});
}

class UpdateImmunizationUseCase implements UseCase<ImmunizationEntity, UpdateImmunizationParams> {
  final ImmunizationRepository repository;
  UpdateImmunizationUseCase(this.repository);

  @override
  Future<Either<Failure, ImmunizationEntity>> call(UpdateImmunizationParams params) {
    return repository.updateImmunizationStatus(params.immunization, params.userId);
  }
}
