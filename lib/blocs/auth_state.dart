enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? userEmail;
  final String? error;

  const AuthState._({
    required this.status,
    this.userEmail,
    this.error,
  });

  factory AuthState.initial() => const AuthState._(
    status: AuthStatus.initial,
  );

  AuthState copyWith({
    AuthStatus? status,
    String? userEmail,
    String? error,
  }) {
    return AuthState._(
      status: status ?? this.status,
      userEmail: userEmail ?? this.userEmail,
      error: error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.userEmail == userEmail &&
        other.error == error;
  }

  @override
  int get hashCode => status.hashCode ^ userEmail.hashCode ^ error.hashCode;
}