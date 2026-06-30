import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/milestone_entity.dart';
import '../../domain/repositories/milestone_repository.dart';
import '../datasources/milestone_local_data_source.dart';
import '../datasources/milestone_remote_data_source.dart';
import '../models/milestone_model.dart';

class MilestoneRepositoryImpl implements MilestoneRepository {
  final MilestoneRemoteDataSource remoteDataSource;
  final MilestoneLocalDataSource localDataSource;

  MilestoneRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<MilestoneEntity>>> getMilestones(String userId, String childId) async {
    try {
      final cached = await localDataSource.getCachedMilestones(childId);
      if (cached.isNotEmpty) {
        remoteDataSource.getMilestones(userId, childId).then((remote) {
          localDataSource.cacheMilestones(childId, remote);
        }).catchError((_) {});
        return Right(cached);
      }
      final remote = await remoteDataSource.getMilestones(userId, childId);
      await localDataSource.cacheMilestones(childId, remote);
      return Right(remote);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MilestoneEntity>> toggleMilestoneStatus(MilestoneEntity milestone, String userId) async {
    try {
      final model = MilestoneModel(
        id: milestone.id,
        childId: milestone.childId,
        title: milestone.title,
        domain: milestone.domain,
        targetAgeBand: milestone.targetAgeBand,
        maxMonthBand: milestone.maxMonthBand,
        isAchieved: !milestone.isAchieved,
        achievedDate: !milestone.isAchieved ? DateTime.now() : null,
        notes: milestone.notes,
      );
      final remote = await remoteDataSource.updateMilestone(model, userId);
      return Right(remote);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
