part of 'auth_bloc.dart';

@immutable
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial() : this._();

  const AuthInitial._({
    this.isLogin = true,
    this.selectedRole = UserRole.passenger,
    this.privacyAccepted = false,
    this.isLoading = false,
    this.emailError,
    this.passwordError,
    this.privacyError,
    this.generalError,
  });

  final bool isLogin;
  final UserRole selectedRole;
  final bool privacyAccepted;
  final bool isLoading;
  final String? emailError;
  final String? passwordError;
  final String? privacyError;
  final String? generalError;

  bool get hasValidationErrors =>
      emailError != null || passwordError != null || privacyError != null;

  AuthInitial copyWith({
    bool? isLogin,
    UserRole? selectedRole,
    bool? privacyAccepted,
    bool? isLoading,
    String? emailError,
    String? passwordError,
    String? privacyError,
    String? generalError,
    bool clearEmailError = false,
    bool clearPasswordError = false,
    bool clearPrivacyError = false,
    bool clearGeneralError = false,
  }) {
    return AuthInitial._(
      isLogin: isLogin ?? this.isLogin,
      selectedRole: selectedRole ?? this.selectedRole,
      privacyAccepted: privacyAccepted ?? this.privacyAccepted,
      isLoading: isLoading ?? this.isLoading,
      emailError: clearEmailError ? null : emailError ?? this.emailError,
      passwordError: clearPasswordError
          ? null
          : passwordError ?? this.passwordError,
      privacyError: clearPrivacyError
          ? null
          : privacyError ?? this.privacyError,
      generalError: clearGeneralError
          ? null
          : generalError ?? this.generalError,
    );
  }
}

final class AuthSuccess extends AuthState {
  const AuthSuccess(this.response);

  final AuthResponse response;
}
