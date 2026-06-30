import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/child_entity.dart';
import '../entities/growth_log_entity.dart';
import '../repositories/child_growth_repository.dart';

class GetChildrenParams {
  final String userId;
  GetChildrenParams(this.userId);
}

class GetChildrenUseCase implements UseCase<List<ChildEntity>, GetChildrenParams> {
  final ChildGrowthRepository repository;
  GetChildrenUseCase(this.repository);

  @override
  Future<Either<Failure, List<ChildEntity>>> call(GetChildrenParams params) {
    return repository.getChildren(params.userId);
  }
}

class AddChildParams {
  final ChildEntity child;
  final String userId;
  AddChildParams({required this.child, required this.userId});
}

class AddChildUseCase implements UseCase<ChildEntity, AddChildParams> {
  final ChildGrowthRepository repository;
  AddChildUseCase(this.repository);

  @override
  Future<Either<Failure, ChildEntity>> call(AddChildParams params) {
    return repository.addChild(params.child, params.userId);
  }
}

class LogGrowthParams {
  final GrowthLogEntity log;
  final ChildEntity child;
  final String userId;
  LogGrowthParams({required this.log, required this.child, required this.userId});
}

class LogGrowthUseCase implements UseCase<GrowthLogEntity, LogGrowthParams> {
  final ChildGrowthRepository repository;
  LogGrowthUseCase(this.repository);

  @override
  Future<Either<Failure, GrowthLogEntity>> call(LogGrowthParams params) {
    return repository.logGrowth(params.log, params.child, params.userId);
  }
}

class GetGrowthLogsParams {
  final String userId;
  final ChildEntity child;
  GetGrowthLogsParams({required this.userId, required this.child});
}

class GetGrowthLogsUseCase implements UseCase<List<GrowthLogEntity>, GetGrowthLogsParams> {
  final ChildGrowthRepository repository;
  GetGrowthLogsUseCase(this.repository);

  @override
  Future<Either<Failure, List<GrowthLogEntity>>> call(GetGrowthLogsParams params) {
    return repository.getGrowthLogs(params.userId, params.child);
  }
}
