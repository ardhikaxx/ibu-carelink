class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Terjadi kesalahan pada server Firebase']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Terjadi kesalahan penyimpanan lokal']);
}

class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'Gagal melakukan autentikasi']);
}
