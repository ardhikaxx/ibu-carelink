import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/milestone_entity.dart';
import '../repositories/milestone_repository.dart';

class GetMilestonesParams {
  final String userId;
  final String childId;
  GetMilestonesParams({required this.userId, required this.childId});
}

class GetMilestonesUseCase implements UseCase<List<MilestoneEntity>, GetMilestonesParams> {
  final MilestoneRepository repository;
  GetMilestonesUseCase(this.repository);

  @override
  Future<Either<Failure, List<MilestoneEntity>>> call(GetMilestonesParams params) {
    return repository.getMilestones(params.userId, params.childId);
  }
}

class ToggleMilestoneParams {
  final MilestoneEntity milestone;
  final String userId;
  ToggleMilestoneParams({required this.milestone, required this.userId});
}

class ToggleMilestoneUseCase implements UseCase<MilestoneEntity, ToggleMilestoneParams> {
  final MilestoneRepository repository;
  ToggleMilestoneUseCase(this.repository);

  @override
  Future<Either<Failure, MilestoneEntity>> call(ToggleMilestoneParams params) {
    return repository.toggleMilestoneStatus(params.milestone, params.userId);
  }
}
