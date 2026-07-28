enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthState {
  const AuthState({
    required this.status,
    this.userId,
  });

  final AuthStatus status;
  final String? userId;
}
