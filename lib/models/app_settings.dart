class AppSettings {
  final String name;
  final String currency;
  final double monthlyBudget;
  final double hourlyWage;
  final double availableResources;
  final int allocationDay; // The day of the month/week allocation happens
  final String allocationFrequency; // 'Daily', 'Weekly', 'Monthly', 'Yearly'
  final bool onboardingComplete;
  final bool soundsEnabled;
  final bool isPro;
  final bool tosAccepted;
  final bool tutorialSeen;
  final bool isSalaryEarner;
  final double salaryAmount;
  final String salaryFrequency;

  AppSettings({
    required this.name,
    required this.currency,
    required this.monthlyBudget,
    required this.hourlyWage,
    required this.availableResources,
    this.allocationDay = 1,
    this.allocationFrequency = 'Monthly',
    this.onboardingComplete = false,
    this.soundsEnabled = true,
    this.isPro = false,
    this.tosAccepted = false,
    this.tutorialSeen = false,
    this.isSalaryEarner = false,
    this.salaryAmount = 0.0,
    this.salaryFrequency = 'Monthly',
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
    bool? soundsEnabled,
    bool? isPro,
    bool? tosAccepted,
    bool? tutorialSeen,
    bool? isSalaryEarner,
    double? salaryAmount,
    String? salaryFrequency,
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
      soundsEnabled: soundsEnabled ?? this.soundsEnabled,
      isPro: isPro ?? this.isPro,
      tosAccepted: tosAccepted ?? this.tosAccepted,
      tutorialSeen: tutorialSeen ?? this.tutorialSeen,
      isSalaryEarner: isSalaryEarner ?? this.isSalaryEarner,
      salaryAmount: salaryAmount ?? this.salaryAmount,
      salaryFrequency: salaryFrequency ?? this.salaryFrequency,
    );
  }
}