class ServerException implements Exception {
  final String message;

  ServerException(this.message);
}

class BadFilter implements Exception {
  final String message;

  BadFilter(this.message);
}
