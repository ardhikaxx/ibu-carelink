import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/emergency_alert.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../datasources/emergency_remote_data_source.dart';
import '../models/emergency_alert_model.dart';

class EmergencyRepositoryImpl implements EmergencyRepository {
  final EmergencyRemoteDataSource remoteDataSource;

  EmergencyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, EmergencyAlert>> createAlert(EmergencyAlert alert) async {
    try {
      final model = EmergencyAlertModel(
        id: alert.id,
        triggeredAt: alert.triggeredAt,
        latitude: alert.latitude,
        longitude: alert.longitude,
        status: alert.status,
        notifiedContacts: alert.notifiedContacts,
      );
      final result = await remoteDataSource.createAlert(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
