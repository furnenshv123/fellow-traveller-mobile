class ProfileValidators {
  ProfileValidators._();

  static final RegExp _fullNameWord = RegExp(
    r"^[А-ЯЁа-яёA-Za-z][А-ЯЁа-яёA-Za-z\-']+$",
  );

  static final RegExp _phoneComplete = RegExp(
    r'^\+375 \((\d{2})\) (\d{3})-(\d{2})-(\d{2})$',
  );

  static final RegExp _carModel = RegExp(
    r'^[A-Za-z][A-Za-z0-9\s\-]{1,}$',
  );

  static final RegExp _licensePlate = RegExp(
    r'^\d{4} [A-Z]{2}-\d$',
  );

  static String? fullName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Укажите ФИО';
    }

    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();

    if (parts.length < 2 || parts.length > 3) {
      return 'Укажите 2 или 3 слова, например: Иван Иванов';
    }

    for (final String part in parts) {
      if (!_fullNameWord.hasMatch(part)) {
        return 'Каждое слово — только буквы, например: Иван Иванов Иванович';
      }
    }

    return null;
  }

  static String? phone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Укажите телефон';
    }
    if (!_phoneComplete.hasMatch(trimmed)) {
      return 'Формат: +375 (29) 123-45-67';
    }
    return null;
  }

  static String? carModel(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Укажите модель';
    }
    if (!_carModel.hasMatch(trimmed)) {
      return 'Модель на латинице, например: Toyota Camry';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(trimmed)) {
      return 'Модель должна содержать буквы';
    }
    return null;
  }

  static String? carLicense(String? value) {
    final trimmed = value?.trim().toUpperCase() ?? '';
    if (trimmed.isEmpty) {
      return 'Укажите госномер';
    }
    if (!_licensePlate.hasMatch(trimmed)) {
      return 'Формат: 1234 AB-7';
    }
    return null;
  }
}
