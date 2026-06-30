import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/child_entity.dart';
import '../entities/growth_log_entity.dart';

abstract class ChildGrowthRepository {
  Future<Either<Failure, List<ChildEntity>>> getChildren(String userId);
  Future<Either<Failure, ChildEntity>> addChild(ChildEntity child, String userId);
  Future<Either<Failure, GrowthLogEntity>> logGrowth(GrowthLogEntity log, ChildEntity child, String userId);
  Future<Either<Failure, List<GrowthLogEntity>>> getGrowthLogs(String userId, ChildEntity child);
}
