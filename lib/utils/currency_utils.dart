class CurrencyUtils {
  static const List<String> currencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'CAD',
    'AUD',
    'CHF',
    'CNY',
    'INR',
    'BRL',
    'MXN',
    'NGN',
  ];

  static String getSymbol(String code) {
    switch (code) {
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'INR':
        return '₹';
      case 'NGN':
        return '₦';
      default:
        return '\$';
    }
  }
}
