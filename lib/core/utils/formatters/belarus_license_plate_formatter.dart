import 'package:flutter/services.dart';

/// Formats input as 1234 AB-7 (Belarus plate) while typing.
class BelarusLicensePlateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final parts = _extractParts(newValue.text);
    final formatted = _formatParts(parts);

    final charsBeforeCursor = _charsBeforeIndex(
      newValue.text,
      newValue.selection.baseOffset,
    );
    final offset = _offsetForCharCount(formatted, charsBeforeCursor);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }

  static _PlateParts _extractParts(String value) {
    final digits = <String>[];
    final letters = <String>[];
    final suffixDigits = <String>[];

    for (final char in value.toUpperCase().split('')) {
      if (RegExp(r'\d').hasMatch(char)) {
        if (digits.length < 4) {
          digits.add(char);
        } else if (letters.length >= 2 && suffixDigits.isEmpty) {
          suffixDigits.add(char);
        }
      } else if (RegExp(r'[A-Z]').hasMatch(char)) {
        if (digits.length == 4 && letters.length < 2) {
          letters.add(char);
        }
      }
    }

    return _PlateParts(
      digits: digits.join(),
      letters: letters.join(),
      suffixDigit: suffixDigits.join(),
    );
  }

  static String _formatParts(_PlateParts parts) {
    if (parts.digits.isEmpty &&
        parts.letters.isEmpty &&
        parts.suffixDigit.isEmpty) {
      return '';
    }

    final buffer = StringBuffer(parts.digits);

    if (parts.digits.length == 4 && parts.letters.isNotEmpty) {
      buffer.write(' ');
      buffer.write(parts.letters);
    }

    if (parts.digits.length == 4 &&
        parts.letters.length == 2 &&
        parts.suffixDigit.isNotEmpty) {
      buffer.write('-');
      buffer.write(parts.suffixDigit);
    }

    return buffer.toString();
  }

  static int _charsBeforeIndex(String text, int index) {
    final safeIndex = index.clamp(0, text.length);
    var count = 0;
    for (var i = 0; i < safeIndex; i++) {
      final char = text[i].toUpperCase();
      if (RegExp(r'[A-Z0-9]').hasMatch(char)) {
        count++;
      }
    }
    return count;
  }

  static int _offsetForCharCount(String formatted, int charCount) {
    if (charCount <= 0) {
      return 0;
    }

    var count = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (RegExp(r'[A-Z0-9]').hasMatch(formatted[i])) {
        count++;
        if (count >= charCount) {
          return i + 1;
        }
      }
    }
    return formatted.length;
  }
}

class _PlateParts {
  const _PlateParts({
    required this.digits,
    required this.letters,
    required this.suffixDigit,
  });

  final String digits;
  final String letters;
  final String suffixDigit;
}
