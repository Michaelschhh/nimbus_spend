class AppSettings {
  final String name;
  final String currency;
  final double monthlyBudget;
  final double hourlyWage;
  final double availableResources;
  final int allocationDay; // The day of the month/week allocation happens
  final String allocationFrequency; // 'Daily', 'Weekly', 'Monthly', 'Yearly'
  final bool onboardingComplete;

  AppSettings({
    required this.name,
    required this.currency,
    required this.monthlyBudget,
    required this.hourlyWage,
    required this.availableResources,
    this.allocationDay = 1,
    this.allocationFrequency = 'Monthly',
    this.onboardingComplete = false,
  });

  AppSettings copyWith({
    String? name,
    String? currency,
    double? monthlyBudget,
    double? hourlyWage,
    double? availableResources,
    int? allocationDay,
    String? allocationFrequency,
    bool? onboardingComplete,
  }) {
    return AppSettings(
      name: name ?? this.name,
      currency: currency ?? this.currency,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      hourlyWage: hourlyWage ?? this.hourlyWage,
      availableResources: availableResources ?? this.availableResources,
      allocationDay: allocationDay ?? this.allocationDay,
      allocationFrequency: allocationFrequency ?? this.allocationFrequency,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}