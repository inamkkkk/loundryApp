import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _pkrFormatter = NumberFormat.currency(
    locale: 'en_PK',
    symbol: 'PKR ',
    decimalDigits: 0,
  );

  static String format(num amount) {
    return _pkrFormatter.format(amount);
  }
}
