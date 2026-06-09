import 'package:fellow_traveller_mobile/core/components/app_screen_body.dart';
import 'package:fellow_traveller_mobile/core/components/custom_button.dart';
import 'package:fellow_traveller_mobile/core/enums/user_role.dart';
import 'package:fellow_traveller_mobile/core/utils/profile_navigation.dart';
import 'package:fellow_traveller_mobile/core/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthSuccess ||
          (current is AuthInitial && current.generalError != null),
      listener: (context, state) async {
        if (state is AuthSuccess) {
          final route = await ProfileNavigation.resolvePostAuthRoute(
            authResponse: state.response,
          );
          if (!context.mounted) {
            return;
          }
          context.go(route);
          return;
        }

        if (state is AuthInitial && state.generalError != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.generalError!),
                action: SnackBarAction(
                  label: 'OK',
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthErrorDismissed());
                  },
                ),
              ),
            );
        }
      },
      builder: (context, state) {
        final form = state is AuthInitial ? state : const AuthInitial();

        return Scaffold(
          body: AppScreenBody(
            child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.scaffoldDark, AppColors.scaffoldDarkMid],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppColors.radiusLg),
                    border: Border.all(color: AppColors.border),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.scaffoldDark.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        form.isLogin ? 'Вход' : 'Регистрация',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _AuthTextField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'example@mail.com',
                        errorText: form.emailError,
                        enabled: !form.isLoading,
                      ),
                      const SizedBox(height: 18),
                      _AuthTextField(
                        label: 'Пароль',
                        controller: _passwordController,
                        obscureText: !_passwordVisible,
                        hintText: '••••••••',
                        errorText: form.passwordError,
                        enabled: !form.isLoading,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Роль',
                        style: TextStyle(
                          color: AppColors.textBody,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(AppColors.radiusMd),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        child: Column(
                          children: <Widget>[
                            _RoleOption(
                              label: 'Пассажир',
                              isSelected:
                                  form.selectedRole == UserRole.passenger,
                              onTap: form.isLoading
                                  ? null
                                  : () => context.read<AuthBloc>().add(
                                      const AuthRoleSelected(
                                        UserRole.passenger,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 8),
                            _RoleOption(
                              label: 'Водитель',
                              isSelected: form.selectedRole == UserRole.driver,
                              onTap: form.isLoading
                                  ? null
                                  : () => context.read<AuthBloc>().add(
                                      const AuthRoleSelected(UserRole.driver),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      if (!form.isLogin) ...<Widget>[
                        const SizedBox(height: 20),
                        _PrivacyPolicyCheckbox(
                          accepted: form.privacyAccepted,
                          errorText: form.privacyError,
                          enabled: !form.isLoading,
                          onChanged: (value) {
                            context.read<AuthBloc>().add(
                              AuthPrivacyAcceptedChanged(value),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 28),
                      CustomButton(
                        text: form.isLogin ? 'Войти' : 'Зарегистрироваться',
                        borderRadius: AppColors.radiusMd,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        onPressed: form.isLoading ? () {} : _submit,
                        backgroundColor: form.isLoading
                            ? AppColors.inputBorder
                            : AppColors.primary,
                      ),
                      if (form.isLoading) ...<Widget>[
                        const SizedBox(height: 16),
                        const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            children: <InlineSpan>[
                              TextSpan(
                                text: form.isLogin
                                    ? 'Нет аккаунта? '
                                    : 'Есть аккаунт? ',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              TextSpan(
                                text: form.isLogin
                                    ? 'Зарегистрироваться'
                                    : 'Войти',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = form.isLoading
                                      ? null
                                      : () => context.read<AuthBloc>().add(
                                          const AuthModeToggled(),
                                        ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ),
        );
      },
    );
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      AuthSubmitted(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.hintText,
    this.errorText,
    this.enabled = true,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? hintText;
  final String? errorText;
  final bool enabled;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textBody,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            errorText: errorText,
            filled: true,
            fillColor: AppColors.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null
                    ? Theme.of(context).colorScheme.error
                    : AppColors.inputBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null
                    ? Theme.of(context).colorScheme.error
                    : AppColors.inputFocused,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: suffixIcon,
          ),
          style: const TextStyle(
            color: AppColors.textBody,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: <Widget>[
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textMuted,
                width: 2,
              ),
            ),
            child: isSelected
                ? Container(
                    margin: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textBody,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyPolicyCheckbox extends StatelessWidget {
  const _PrivacyPolicyCheckbox({
    required this.accepted,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  final bool accepted;
  final ValueChanged<bool> onChanged;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: accepted,
                onChanged: enabled
                    ? (value) => onChanged(value ?? false)
                    : null,
                activeColor: AppColors.primary,
                side: BorderSide(
                  color: errorText != null
                      ? Theme.of(context).colorScheme.error
                      : AppColors.inputBorder,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(
                    color: AppColors.textBody,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  children: <InlineSpan>[
                    const TextSpan(text: 'Я принимаю '),
                    TextSpan(
                      text: 'политику конфиденциальности',
                      style: const TextStyle(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // TODO: open privacy policy URL or screen
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (errorText != null) ...<Widget>[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Text(
              errorText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
