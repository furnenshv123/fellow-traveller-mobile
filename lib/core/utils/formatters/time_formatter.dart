import 'dart:math' as math;

import 'package:flutter/services.dart';

/// Formats input as HH:MM while typing.
class TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final limited = digits.substring(0, math.min(4, digits.length));
    final formatted = _formatDigits(limited);

    final digitsBeforeCursor = _digitsBeforeIndex(
      newValue.text,
      newValue.selection.baseOffset,
    );
    final offset = _offsetForDigitCount(formatted, digitsBeforeCursor);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }

  static String _formatDigits(String digits) {
    if (digits.length <= 2) {
      return digits;
    }
    return '${digits.substring(0, 2)}:${digits.substring(2)}';
  }

  static int _digitsBeforeIndex(String text, int index) {
    final safeIndex = index.clamp(0, text.length);
    return text.substring(0, safeIndex).replaceAll(RegExp(r'\D'), '').length;
  }

  static int _offsetForDigitCount(String formatted, int digitCount) {
    if (digitCount <= 0) {
      return 0;
    }

    var count = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        count++;
        if (count >= digitCount) {
          return i + 1;
        }
      }
    }
    return formatted.length;
  }
}
