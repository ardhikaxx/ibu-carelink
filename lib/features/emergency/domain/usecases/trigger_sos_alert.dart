import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/emergency_alert.dart';
import '../repositories/emergency_repository.dart';
import '../services/location_service.dart';

class TriggerSosAlert implements UseCase<EmergencyAlert, NoParams> {
  final EmergencyRepository repository;
  final LocationService locationService;

  const TriggerSosAlert({required this.repository, required this.locationService});

  @override
  Future<Either<Failure, EmergencyAlert>> call(NoParams params) async {
    final positionResult = await locationService.getCurrentPosition();

    return positionResult.fold(
      (failure) => Left(failure),
      (position) async {
        final alert = EmergencyAlert(
          triggeredAt: DateTime.now(),
          latitude: position.latitude,
          longitude: position.longitude,
          status: AlertStatus.active,
        );

        return repository.createAlert(alert);
      },
    );
  }
}
