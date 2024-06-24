import 'package:intl/intl.dart';

class AppUtil {
  static final formatter = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

  static String formatPrice(int price) {
    return formatter.format(price);
  }
}