class RideValidators {
  RideValidators._();

  static final RegExp _time = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');

  static String? time(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Укажите время';
    }
    if (!_time.hasMatch(trimmed)) {
      return 'Формат: ЧЧ:ММ (00:00–23:59)';
    }
    return null;
  }

  static String? seats(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Укажите количество мест';
    }
    final seats = int.tryParse(trimmed);
    if (seats == null || seats < 1) {
      return 'Минимум 1 место';
    }
    if (seats > 8) {
      return 'Не более 8 мест';
    }
    return null;
  }

  static String? price(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Укажите цену';
    }
    final price = double.tryParse(trimmed.replaceAll(',', '.'));
    if (price == null || price <= 0) {
      return 'Цена должна быть больше 0';
    }
    if (price > 1000000) {
      return 'Слишком большая цена';
    }
    return null;
  }

  static String? dateIso(String? iso) {
    if (iso == null || iso.isEmpty) {
      return 'Выберите дату';
    }
    final parts = iso.split('-');
    if (parts.length != 3) {
      return 'Некорректная дата';
    }
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return 'Некорректная дата';
    }
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return 'Некорректная дата';
    }
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (date.isBefore(todayDate)) {
      return 'Дата не может быть в прошлом';
    }
    return null;
  }

  static String? routePoints({required int? fromId, required int? toId}) {
    if (fromId == null || toId == null) {
      return 'Выберите пункты отправления и назначения';
    }
    if (fromId == toId) {
      return 'Выберите разные города';
    }
    return null;
  }
}
