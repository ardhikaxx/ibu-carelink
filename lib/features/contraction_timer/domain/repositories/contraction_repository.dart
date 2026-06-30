import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/contraction_entity.dart';

abstract class ContractionRepository {
  Future<Either<Failure, ContractionEntity>> saveContraction(ContractionEntity contraction, String userId);
  Future<Either<Failure, List<ContractionEntity>>> getContractions(String userId, String pregnancyId);
}
