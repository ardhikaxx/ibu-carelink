import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Terjadi kesalahan pada server Firebase']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Terjadi kesalahan pada penyimpanan lokal']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Autentikasi gagal. Periksa email atau kata sandi Anda.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Koneksi jaringan terputus']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Izin akses ditolak']);
}
