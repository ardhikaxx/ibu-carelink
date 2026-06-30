import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

class GeoPosition {
  final double latitude;
  final double longitude;

  const GeoPosition({required this.latitude, required this.longitude});
}

abstract class LocationService {
  Future<Either<Failure, GeoPosition>> getCurrentPosition();
}
