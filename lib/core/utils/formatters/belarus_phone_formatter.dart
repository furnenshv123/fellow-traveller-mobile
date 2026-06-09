import 'dart:math' as math;

import 'package:flutter/services.dart';

/// Formats input as +375 (XX) XXX-XX-XX while typing.
class BelarusPhoneFormatter extends TextInputFormatter {
  static const String emptyDisplay = '+375 (';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = _digitsOnly(newValue.text);
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    var normalized = digits;
    if (normalized.startsWith('375')) {
      normalized = normalized.substring(0, math.min(12, normalized.length));
    } else {
      normalized = '375$normalized';
      normalized = normalized.substring(0, math.min(12, normalized.length));
    }

    final formatted = _formatDigits(normalized);
    final digitsBeforeCursor = _digitsBeforeIndex(
      newValue.text,
      newValue.selection.baseOffset,
    );
    final offset = _offsetForDigitCount(formatted, digitsBeforeCursor);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  static String _formatDigits(String digits) {
    if (digits.length <= 3) {
      return emptyDisplay;
    }

    final national = digits.substring(3);
    final buffer = StringBuffer('+375 (');

    if (national.isEmpty) {
      return emptyDisplay;
    }

    if (national.length <= 2) {
      buffer.write(national);
      return buffer.toString();
    }

    buffer.write(national.substring(0, 2));
    buffer.write(') ');

    final tail = national.substring(2);
    if (tail.isEmpty) {
      return buffer.toString();
    }

    if (tail.length <= 3) {
      buffer.write(tail);
      return buffer.toString();
    }

    buffer.write(tail.substring(0, 3));
    buffer.write('-');

    if (tail.length <= 5) {
      buffer.write(tail.substring(3));
      return buffer.toString();
    }

    buffer.write(tail.substring(3, 5));
    buffer.write('-');
    buffer.write(tail.substring(5, math.min(7, tail.length)));

    return buffer.toString();
  }

  static String _digitsOnly(String value) =>
      value.replaceAll(RegExp(r'\D'), '');

  static int _digitsBeforeIndex(String text, int index) {
    final safeIndex = index.clamp(0, text.length);
    return _digitsOnly(text.substring(0, safeIndex)).length;
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
