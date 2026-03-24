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
  final bool adsRemoved;
  final bool tosAccepted;
  final bool tutorialSeen;
  final bool isSalaryEarner;
  final double salaryAmount;
  final String salaryFrequency;
  final bool isDarkMode;
  final int themeIndex;
  final bool themesUnlocked;
  final bool mascotEnabled;
  final bool mascotTipsEnabled;
  final bool appLockEnabled;
  final String appLockType; // 'passcode' | 'password'
  final String appLockCode;
  final bool securityUnlocked; // Non-persistent session state
  final bool securityUnlockedIAP; // Persisted IAP state
  final int? themeExpiryTimestamp; // UTC milliseconds
  final bool performanceModeEnabled; // Optimization for low-end devices
  final bool motionBlurEnabled;      // Visual polish for transitions
  final bool biometricEnabled;       // Fingerprint / Face unlock



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
    this.adsRemoved = false,
    this.tosAccepted = false,
    this.tutorialSeen = false,
    this.isSalaryEarner = false,
    this.salaryAmount = 0.0,
    this.salaryFrequency = 'Monthly',
    this.isDarkMode = true,
    this.themeIndex = 0,
    this.themesUnlocked = false,
    this.mascotEnabled = true,
    this.mascotTipsEnabled = true,
    this.appLockEnabled = false,
    this.appLockType = 'passcode',
    this.appLockCode = '',
    this.securityUnlocked = false,
    this.securityUnlockedIAP = false,
    this.themeExpiryTimestamp,
    this.performanceModeEnabled = false,
    this.motionBlurEnabled = true,
    this.biometricEnabled = false,
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
    bool? adsRemoved,
    bool? tosAccepted,
    bool? tutorialSeen,
    bool? isSalaryEarner,
    double? salaryAmount,
    String? salaryFrequency,
    bool? isDarkMode,
    int? themeIndex,
    bool? themesUnlocked,
    bool? mascotEnabled,
    bool? mascotTipsEnabled,
    bool? appLockEnabled,
    String? appLockType,
    String? appLockCode,
    bool? securityUnlocked,
    bool? securityUnlockedIAP,
    int? themeExpiryTimestamp,
    bool? performanceModeEnabled,
    bool? motionBlurEnabled,
    bool? biometricEnabled,
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
      adsRemoved: adsRemoved ?? this.adsRemoved,
      tosAccepted: tosAccepted ?? this.tosAccepted,
      tutorialSeen: tutorialSeen ?? this.tutorialSeen,
      isSalaryEarner: isSalaryEarner ?? this.isSalaryEarner,
      salaryAmount: salaryAmount ?? this.salaryAmount,
      salaryFrequency: salaryFrequency ?? this.salaryFrequency,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      themeIndex: themeIndex ?? this.themeIndex,
      themesUnlocked: themesUnlocked ?? this.themesUnlocked,
      mascotEnabled: mascotEnabled ?? this.mascotEnabled,
      mascotTipsEnabled: mascotTipsEnabled ?? this.mascotTipsEnabled,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      appLockType: appLockType ?? this.appLockType,
      appLockCode: appLockCode ?? this.appLockCode,
      securityUnlocked: securityUnlocked ?? this.securityUnlocked,
      securityUnlockedIAP: securityUnlockedIAP ?? this.securityUnlockedIAP,
      themeExpiryTimestamp: themeExpiryTimestamp ?? this.themeExpiryTimestamp,
      performanceModeEnabled: performanceModeEnabled ?? this.performanceModeEnabled,
      motionBlurEnabled: motionBlurEnabled ?? this.motionBlurEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );


  }
}