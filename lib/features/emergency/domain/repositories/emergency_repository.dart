import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/emergency_alert.dart';

abstract class EmergencyRepository {
  Future<Either<Failure, EmergencyAlert>> createAlert(EmergencyAlert alert);
}
