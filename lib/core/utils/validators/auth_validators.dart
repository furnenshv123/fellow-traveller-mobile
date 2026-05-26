class AuthValidators {
  const AuthValidators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Введите email';
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Введите корректный email';
    }
    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Введите пароль';
    }
    if (password.length < 8) {
      return 'Пароль должен быть не короче 8 символов';
    }
    return null;
  }

  static String? privacyAccepted({required bool accepted, required bool isLogin}) {
    if (isLogin || accepted) {
      return null;
    }
    return 'Необходимо принять политику конфиденциальности';
  }
}
