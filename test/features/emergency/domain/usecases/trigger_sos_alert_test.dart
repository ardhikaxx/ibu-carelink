import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ibu_carelink/core/errors/failures.dart';
import 'package:ibu_carelink/core/usecases/usecase.dart';
import 'package:ibu_carelink/features/emergency/domain/entities/emergency_alert.dart';
import 'package:ibu_carelink/features/emergency/domain/repositories/emergency_repository.dart';
import 'package:ibu_carelink/features/emergency/domain/services/location_service.dart';
import 'package:ibu_carelink/features/emergency/domain/usecases/trigger_sos_alert.dart';

class MockEmergencyRepository extends Mock implements EmergencyRepository {}
class MockLocationService extends Mock implements LocationService {}
class FakeEmergencyAlert extends Fake implements EmergencyAlert {}

void main() {
  late TriggerSosAlert useCase;
  late MockEmergencyRepository mockRepository;
  late MockLocationService mockLocationService;

  setUpAll(() {
    registerFallbackValue(FakeEmergencyAlert());
  });

  setUp(() {
    mockRepository = MockEmergencyRepository();
    mockLocationService = MockLocationService();
    useCase = TriggerSosAlert(repository: mockRepository, locationService: mockLocationService);
  });

  const tGeoPosition = GeoPosition(latitude: -6.200000, longitude: 106.816666);
  final tAlert = EmergencyAlert(
    id: '1',
    triggeredAt: DateTime.now(),
    latitude: tGeoPosition.latitude,
    longitude: tGeoPosition.longitude,
    status: AlertStatus.active,
  );

  test('should get current location and create alert in repository', () async {
    // arrange
    when(() => mockLocationService.getCurrentPosition())
        .thenAnswer((_) async => const Right(tGeoPosition));
    when(() => mockRepository.createAlert(any()))
        .thenAnswer((_) async => Right(tAlert));

    // act
    final result = await useCase(NoParams());

    // assert
    expect(result, Right(tAlert));
    verify(() => mockLocationService.getCurrentPosition()).called(1);
    verify(() => mockRepository.createAlert(any())).called(1);
  });

  test('should return failure when location service fails', () async {
    // arrange
    when(() => mockLocationService.getCurrentPosition())
        .thenAnswer((_) async => const Left(PermissionFailure('Izin lokasi ditolak')));

    // act
    final result = await useCase(NoParams());

    // assert
    expect(result, const Left(PermissionFailure('Izin lokasi ditolak')));
    verify(() => mockLocationService.getCurrentPosition()).called(1);
    verifyNever(() => mockRepository.createAlert(any()));
  });
}
