sealed class AppError implements Exception {
  final String message;
  final Exception? cause;
  AppError(this.message, {this.cause});
  @override
  String toString() => message;
}

final class AuthError extends AppError { AuthError(super.message, {super.cause}); }
final class ValidationError extends AppError { ValidationError(super.message, {super.cause}); }
final class SyncError extends AppError { SyncError(super.message, {super.cause}); }
final class NetworkError extends AppError { NetworkError(super.message, {super.cause}); }
final class NotFoundError extends AppError { NotFoundError(super.message, {super.cause}); }
final class PermissionError extends AppError { PermissionError(super.message, {super.cause}); }
