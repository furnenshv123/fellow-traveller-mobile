part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {
  const AuthEvent();
}

final class AuthModeToggled extends AuthEvent {
  const AuthModeToggled();
}

final class AuthRoleSelected extends AuthEvent {
  const AuthRoleSelected(this.role);

  final UserRole role;
}

final class AuthPrivacyAcceptedChanged extends AuthEvent {
  const AuthPrivacyAcceptedChanged(this.accepted);

  final bool accepted;
}

final class AuthSubmitted extends AuthEvent {
  const AuthSubmitted({required this.email, required this.password});

  final String email;
  final String password;
}

final class AuthErrorDismissed extends AuthEvent {
  const AuthErrorDismissed();
}
