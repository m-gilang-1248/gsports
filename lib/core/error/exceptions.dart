class ServerException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  ServerException(this.message, {this.stackTrace});

  @override
  String toString() {
    return 'ServerException: $message';
  }
}

class CacheException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  CacheException(this.message, {this.stackTrace});

  @override
  String toString() {
    return 'CacheException: $message';
  }
}

class AuthException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  AuthException(this.message, {this.stackTrace});

  @override
  String toString() {
    return 'AuthException: $message';
  }
}
