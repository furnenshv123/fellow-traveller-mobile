import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:fellow_traveller_mobile/core/enums/user_role.dart';
import 'package:fellow_traveller_mobile/core/errors/api_error_mapper.dart';
import 'package:fellow_traveller_mobile/core/features/auth/data/auth_repository.dart';
import 'package:fellow_traveller_mobile/core/features/auth/data/models/auth_response.dart';
import 'package:fellow_traveller_mobile/core/utils/validators/auth_validators.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<AuthModeToggled>(_onModeToggled);
    on<AuthRoleSelected>(_onRoleSelected);
    on<AuthPrivacyAcceptedChanged>(_onPrivacyAcceptedChanged);
    on<AuthSubmitted>(_onSubmitted);
    on<AuthErrorDismissed>(_onErrorDismissed);
  }

  final AuthRepository _authRepository;

  AuthInitial get _formState {
    final current = state;
    if (current is AuthInitial) {
      return current;
    }
    return const AuthInitial();
  }

  void _onModeToggled(AuthModeToggled event, Emitter<AuthState> emit) {
    emit(
      _formState.copyWith(
        isLogin: !_formState.isLogin,
        clearEmailError: true,
        clearPasswordError: true,
        clearPrivacyError: true,
        clearGeneralError: true,
      ),
    );
  }

  void _onRoleSelected(AuthRoleSelected event, Emitter<AuthState> emit) {
    emit(_formState.copyWith(selectedRole: event.role));
  }

  void _onPrivacyAcceptedChanged(
    AuthPrivacyAcceptedChanged event,
    Emitter<AuthState> emit,
  ) {
    emit(
      _formState.copyWith(
        privacyAccepted: event.accepted,
        clearPrivacyError: event.accepted,
      ),
    );
  }

  void _onErrorDismissed(AuthErrorDismissed event, Emitter<AuthState> emit) {
    emit(_formState.copyWith(clearGeneralError: true));
  }

  Future<void> _onSubmitted(
    AuthSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final form = _formState;
    final emailError = AuthValidators.email(event.email);
    final passwordError = AuthValidators.password(event.password);
    final privacyError = AuthValidators.privacyAccepted(
      accepted: form.privacyAccepted,
      isLogin: form.isLogin,
    );

    if (emailError != null || passwordError != null || privacyError != null) {
      emit(
        form.copyWith(
          emailError: emailError,
          passwordError: passwordError,
          privacyError: privacyError,
          clearGeneralError: true,
        ),
      );
      return;
    }

    emit(
      form.copyWith(
        isLoading: true,
        clearEmailError: true,
        clearPasswordError: true,
        clearPrivacyError: true,
        clearGeneralError: true,
      ),
    );

    try {
      final role = form.selectedRole.name;
      final response = form.isLogin
          ? await _authRepository.login(
              email: event.email,
              password: event.password,
              role: role,
            )
          : await _authRepository.register(
              email: event.email,
              password: event.password,
              role: role,
            );

      emit(AuthSuccess(response));
    } on DioException catch (error) {
      emit(
        _formState.copyWith(
          isLoading: false,
          generalError: ApiErrorMapper.fromDioException(error),
        ),
      );
    } catch (_) {
      emit(
        _formState.copyWith(
          isLoading: false,
          generalError: 'Произошла ошибка. Попробуйте снова.',
        ),
      );
    }
  }
}
