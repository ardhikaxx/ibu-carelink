import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/milestone_entity.dart';

abstract class MilestoneRepository {
  Future<Either<Failure, List<MilestoneEntity>>> getMilestones(String userId, String childId);
  Future<Either<Failure, MilestoneEntity>> toggleMilestoneStatus(MilestoneEntity milestone, String userId);
}
