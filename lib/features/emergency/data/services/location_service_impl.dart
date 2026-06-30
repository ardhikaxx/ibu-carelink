import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/services/location_service.dart';

class LocationServiceImpl implements LocationService {
  @override
  Future<Either<Failure, GeoPosition>> getCurrentPosition() async {
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied) {
        return const Left(PermissionFailure('Izin lokasi ditolak. SOS membutuhkan akses lokasi.'));
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return const Left(PermissionFailure(
        'Izin lokasi diblokir permanen. Aktifkan melalui Pengaturan perangkat.',
      ));
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return Right(GeoPosition(
        latitude: position.latitude,
        longitude: position.longitude,
      ));
    } catch (e) {
      return const Left(ServerFailure('Gagal mendapatkan lokasi. Pastikan GPS aktif.'));
    }
  }
}
