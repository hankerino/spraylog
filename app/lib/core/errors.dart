sealed class AppError {
  const AppError(this.message);

  final String message;
}

final class ValidationError extends AppError {
  const ValidationError(super.message);
}

final class NetworkError extends AppError {
  const NetworkError(super.message);
}

final class DatabaseError extends AppError {
  const DatabaseError(super.message);
}

final class AuthenticationError extends AppError {
  const AuthenticationError(super.message);
}

final class UnknownError extends AppError {
  const UnknownError(super.message);
}
