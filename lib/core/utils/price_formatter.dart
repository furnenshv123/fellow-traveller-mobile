abstract final class PriceFormatter {
  /// Formats amount in Belarusian rubles (BYN).
  static String format(num amount) => '${amount.toInt()} Br';
}
