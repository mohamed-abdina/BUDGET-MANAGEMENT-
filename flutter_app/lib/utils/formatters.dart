import 'package:intl/intl.dart';

class Formatters {
  static final _currencyFormat = NumberFormat.currency(
    symbol: 'KES ',
    decimalDigits: 2,
  );

  static final _compactCurrencyFormat = NumberFormat.compactCurrency(
    symbol: 'KES ',
    decimalDigits: 1,
  );

  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _monthFormat = DateFormat('MMMM yyyy');
  static final _dayFormat = DateFormat('EEE, MMM d');

  static String currency(double amount) {
    return _currencyFormat.format(amount);
  }

  static String compactCurrency(double amount) {
    return _compactCurrencyFormat.format(amount);
  }

  static String date(DateTime date) {
    return _dateFormat.format(date);
  }

  static String month(int month, int year) {
    final dt = DateTime(year, month);
    return _monthFormat.format(dt);
  }

  static String day(DateTime date) {
    return _dayFormat.format(date);
  }

  static String monthShort(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}
