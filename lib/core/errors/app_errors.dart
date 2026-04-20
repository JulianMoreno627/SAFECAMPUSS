class AppError implements Exception {
  final String message;
  final String? code;

  AppError(this.message, {this.code});

  @override
  String toString() => message;
}

class AuthError extends AppError {
  AuthError(super.message, {super.code});
}

class NetworkError extends AppError {
  NetworkError(super.message, {super.code});
}

class LocationError extends AppError {
  LocationError(super.message, {super.code});
}

class DatabaseError extends AppError {
  DatabaseError(super.message, {super.code});
}
