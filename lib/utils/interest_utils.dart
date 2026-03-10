class InterestUtils {
  static double calculateSimpleInterest(
    double principal,
    double rate,
    int days,
  ) {
    // Principal * Rate * (Days / 365)
    return principal * (rate / 100) * (days / 365);
  }
}
