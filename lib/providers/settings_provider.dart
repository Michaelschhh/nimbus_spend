import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  String _currentAccountId = 'default';
  String get currentAccountId => _currentAccountId;
  
  String get _pfx => _currentAccountId == 'default' ? '' : '${_currentAccountId}_';

  AppSettings _settings = AppSettings(
    name: 'User', currency: 'USD', monthlyBudget: 1000, 
    hourlyWage: 20, availableResources: 0
  );

  AppSettings get settings => _settings;
  SharedPreferences? _prefs;

  SettingsProvider();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _currentAccountId = _prefs!.getString('current_account_id') ?? 'default';
    await StorageService().switchDatabase(_currentAccountId);
    await _loadSettings(initial: true);
  }

  Future<void> switchAccount(String accountId, Function() onDbSwitched) async {
    _currentAccountId = accountId;
    if (_prefs != null) {
      await _prefs!.setString('current_account_id', accountId);
    }
    await StorageService().switchDatabase(accountId);
    await _loadSettings();
    onDbSwitched(); // trigger refresh in other providers
  }

  Future<void> updateSalarySettings(bool enabled, double amount, String frequency) async {
    if (_prefs == null) return;
    await _prefs!.setBool('${_pfx}is_salary_earner', enabled);
    await _prefs!.setDouble('${_pfx}salary_amount', amount);
    await _prefs!.setString('${_pfx}salary_frequency', frequency);
    await _loadSettings();
  }

  Future<void> toggleMonthlyAllowance(bool value) async {
    if (_prefs == null) return;
    await _prefs!.setBool('${_pfx}has_monthly_allowance', value);
    await _loadSettings();
  }

  Future<void> _loadSettings({bool initial = false}) async {
    if (initial) {
      _isInitializing = true;
      notifyListeners();
    }
    if (_prefs == null) return;
    final prefs = _prefs!;
    _settings = AppSettings(
      name: prefs.getString('${_pfx}user_name') ?? 'User',
      currency: prefs.getString('${_pfx}currency') ?? 'USD',
      monthlyBudget: prefs.getDouble('${_pfx}monthly_budget') ?? 1000,
      hourlyWage: prefs.getDouble('${_pfx}hourly_wage') ?? 20,
      availableResources: prefs.getDouble('${_pfx}available_resources') ?? 0,
      hasMonthlyAllowance: prefs.getBool('${_pfx}has_monthly_allowance') ?? true,
      onboardingComplete: prefs.getBool('${_pfx}onboarding_complete') ?? false,
      isSalaryEarner: prefs.getBool('${_pfx}is_salary_earner') ?? false,
      salaryAmount: prefs.getDouble('${_pfx}salary_amount') ?? 0.0,
      salaryFrequency: prefs.getString('${_pfx}salary_frequency') ?? 'Monthly',
      customCategories: prefs.getStringList('${_pfx}custom_categories') ?? [],
      
      soundsEnabled: prefs.getBool('sounds_enabled') ?? true,
      isPro: prefs.getBool('is_pro') ?? false,
      tosAccepted: prefs.getBool('tos_accepted') ?? false,
      tutorialSeen: prefs.getBool('tutorial_seen') ?? false,
      isDarkMode: prefs.getBool('is_dark_mode') ?? true,
      themeIndex: prefs.getInt('theme_index') == 10 ? 0 : (prefs.getInt('theme_index') ?? 0),
      themesUnlocked: prefs.getBool('themes_unlocked') ?? false,
      themeExpiryTimestamp: prefs.getInt('theme_expiry_timestamp'),
      adsRemoved: prefs.getBool('ads_removed') ?? false,
      performanceModeEnabled: prefs.getBool('performance_mode_enabled') ?? false,
      motionBlurEnabled: prefs.getBool('motion_blur_enabled') ?? true,
      biometricEnabled: prefs.getBool('biometric_enabled') ?? false,
      liquidEffectEnabled: prefs.getInt('theme_index') == 10 ? true : (prefs.getBool('liquid_effect_enabled') ?? false),
      blurIntensity: prefs.getDouble('blur_intensity') ?? 0.1,
      refractionIntensity: prefs.getDouble('refraction_intensity') ?? 0.05,


      mascotEnabled: prefs.getBool('mascot_enabled') ?? true,
      mascotTipsEnabled: prefs.getBool('mascot_tips_enabled') ?? true,
      appLockEnabled: prefs.getBool('app_lock_enabled') ?? false,
      appLockType: prefs.getString('app_lock_type') ?? 'passcode',
      appLockCode: prefs.getString('app_lock_code') ?? '',
      securityUnlocked: _settings.securityUnlocked,
      securityUnlockedIAP: prefs.getBool('security_unlocked_iap') ?? false,
    );
    if (initial) _isInitializing = false;
    notifyListeners();
  }

  // --- Security Logic ---
  void setSecurityUnlocked(bool value) {
    _settings = _settings.copyWith(securityUnlocked: value);
    notifyListeners();
  }

  Future<void> updateSecuritySettings(bool enabled, String type, String code) async {
    if (_prefs == null) return;
    await _prefs!.setBool('app_lock_enabled', enabled);
    await _prefs!.setString('app_lock_type', type);
    await _prefs!.setString('app_lock_code', code);
    await _loadSettings();
  }
  // ----------------------

  // --- Ad Tracking System ---
  int _adClickCounter = 0;
  int get adClickCounter => _adClickCounter;

  void incrementAdCounter() {
    _adClickCounter++;
    notifyListeners();
  }

  void resetAdCounter() {
    _adClickCounter = 0;
    notifyListeners();
  }
  // --------------------------

  Future<void> upgradeToPro() async {
    if (_prefs == null) return;
    await _prefs!.setBool('is_pro', true);
    await _prefs!.setBool('ads_removed', true);
    await _prefs!.setBool('themes_unlocked', true);
    await _prefs!.setBool('security_unlocked_iap', true); // New IAP flag
    await _loadSettings();
  }

  Future<void> removeAds() async {
    if (_prefs == null) return;
    await _prefs!.setBool('ads_removed', true);
    await _loadSettings();
  }

  Future<void> updateResources(double delta) async {
    if (_prefs == null) return;
    double newValue = _settings.availableResources + delta;
    await _prefs!.setDouble('available_resources', newValue);
    _settings = _settings.copyWith(availableResources: newValue);
    notifyListeners();
  }

  Future<void> addRolloverFunds(double amount) async {
    await updateResources(amount);
  }

  Future<void> updateProfile(String name, double budget, double wage, String currency) async {
    if (_prefs == null) return;
    
    await _prefs!.setString('${_pfx}user_name', name);
    await _prefs!.setDouble('${_pfx}monthly_budget', budget);
    await _prefs!.setDouble('${_pfx}hourly_wage', wage);
    await _prefs!.setString('${_pfx}currency', currency);
    
    await _loadSettings();
  }

  Future<void> setDarkMode(bool isDark) async {
    if (_prefs == null) return;
    await _prefs!.setBool('is_dark_mode', isDark);
    await _loadSettings();
  }

  Future<void> setThemeIndex(int index) async {
    if (_prefs == null) return;
    await _prefs!.setInt('theme_index', index);
    await _loadSettings();
  }

  Future<void> setPerformanceMode(bool enabled) async {
    if (_prefs == null) return;
    await _prefs!.setBool('performance_mode_enabled', enabled);
    await _loadSettings();
  }

  Future<void> setMotionBlur(bool enabled) async {
    if (_prefs == null) return;
    await _prefs!.setBool('motion_blur_enabled', enabled);
    await _loadSettings();
  }

  Future<void> setLiquidEffectEnabled(bool enabled) async {
    if (_prefs == null) return;
    await _prefs!.setBool('liquid_effect_enabled', enabled);
    await _loadSettings();
  }

  Future<void> setLiquidIntensities(double blur, double refraction) async {
    if (_prefs == null) return;
    await _prefs!.setDouble('blur_intensity', blur);
    await _prefs!.setDouble('refraction_intensity', refraction);
    await _loadSettings();
  }

  Future<void> setBiometric(bool enabled) async {
    if (_prefs == null) return;
    await _prefs!.setBool('biometric_enabled', enabled);
    await _loadSettings();
  }

  Future<void> setSoundsEnabled(bool enabled) async {
    if (_prefs == null) return;
    await _prefs!.setBool('sounds_enabled', enabled);
    await _loadSettings();
  }

  Future<void> unlockThemes() async {
    if (_prefs == null) return;
    await _prefs!.setBool('themes_unlocked', true);
    await _loadSettings();
  }

  Future<void> unlockSecurity() async {
    if (_prefs == null) return;
    await _prefs!.setBool('security_unlocked_iap', true);
    await _loadSettings();
  }
  
  Future<void> unlockThemeFor24h() async {
    if (_prefs == null) return;
    final expiry = DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch;
    await _prefs!.setInt('theme_expiry_timestamp', expiry);
    await _loadSettings();
  }

  bool isThemeUnlocked() {
    if (_settings.isPro || _settings.themesUnlocked) return true;
    if (_settings.themeExpiryTimestamp != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now < _settings.themeExpiryTimestamp!) return true;
    }
    return false;
  }

  Future<void> setMascotEnabled(bool enabled) async {
    if (_prefs == null) return;
    await _prefs!.setBool('mascot_enabled', enabled);
    await _loadSettings();
  }

  Future<void> setMascotTipsEnabled(bool enabled) async {
    if (_prefs == null) return;
    await _prefs!.setBool('mascot_tips_enabled', enabled);
    await _loadSettings();
  }

  Future<void> completeOnboarding(String name, double budget, double wage, String currency, {double? availableResources, bool? isSalaryEarner, double? salaryAmount}) async {
    if (_prefs == null) return;
    await _prefs!.setString('${_pfx}user_name', name);
    await _prefs!.setDouble('${_pfx}monthly_budget', budget);
    await _prefs!.setDouble('${_pfx}hourly_wage', wage);
    await _prefs!.setString('${_pfx}currency', currency);
    
    // Only set available resources on initial setup
    if (!(_settings.onboardingComplete)) {
      await _prefs!.setDouble('${_pfx}available_resources', availableResources ?? budget);
      
      // Handle salary onboarding
      if (isSalaryEarner != null) {
        await _prefs!.setBool('${_pfx}is_salary_earner', isSalaryEarner);
        await _prefs!.setDouble('${_pfx}salary_amount', salaryAmount ?? 0);
        await _prefs!.setString('${_pfx}salary_frequency', 'Monthly');
      }
      
      await _prefs!.setBool('${_pfx}onboarding_complete', true);
    }
    await _loadSettings();
  }

  Future<void> acceptTOS() async {
    if (_prefs == null) return;
    await _prefs!.setBool('tos_accepted', true);
    await _loadSettings();
  }

  Future<void> completeTutorial() async {
    if (_prefs == null) return;
    await _prefs!.setBool('tutorial_seen', true);
    await _loadSettings();
  }

  Future<void> clearAllData() async {
    // 1. Storage wipe
    await StorageService().clearAll();
    
      // 2. Prefs wipe (only for current instance)
      if (_prefs != null) {
        // Base keys
        await _prefs!.remove('${_pfx}user_name');
        await _prefs!.remove('${_pfx}monthly_budget');
        await _prefs!.remove('${_pfx}hourly_wage');
        await _prefs!.remove('${_pfx}currency');
        await _prefs!.remove('${_pfx}available_resources');
        await _prefs!.setBool('${_pfx}onboarding_complete', false);
        
        // IAP & Premium keys
        await _prefs!.remove('is_pro');
        await _prefs!.remove('ads_removed');
        await _prefs!.remove('themes_unlocked');
        await _prefs!.remove('security_unlocked_iap');
        await _prefs!.remove('theme_expiry_timestamp');
        
        // Settings reset
        await _prefs!.remove('sounds_enabled');
        await _prefs!.remove('is_dark_mode');
        await _prefs!.remove('theme_index');
        await _prefs!.remove('performance_mode_enabled');
        await _prefs!.remove('motion_blur_enabled');
        await _prefs!.remove('liquid_effect_enabled');
        await _prefs!.remove('blur_intensity');
        await _prefs!.remove('refraction_intensity');
        await _prefs!.remove('biometric_enabled');
        await _prefs!.remove('app_lock_enabled');
        await _prefs!.remove('app_lock_type');
        await _prefs!.remove('app_lock_code');
      }
    
    // 3. Reset local state
    _settings = AppSettings(
      name: 'User', currency: 'USD', monthlyBudget: 1000, 
      hourlyWage: 20, availableResources: 0, onboardingComplete: false
    );
    notifyListeners();
  }

  bool isSecurityUnlockedIAP() {
    // Check if security features are paid for
    return _settings.isPro || _settings.securityUnlockedIAP; 
  }

  Future<void> updateAvailableResources(double amount) async {
    if (_prefs == null) return;
    await _prefs!.setDouble('${_pfx}available_resources', amount);
    await _loadSettings();
  }

  Future<void> deductFromResources(double amount) async {
    if (_prefs == null) return;
    double current = _prefs!.getDouble('${_pfx}available_resources') ?? 0;
    await _prefs!.setDouble('${_pfx}available_resources', (current - amount).clamp(0, double.infinity));
    await _loadSettings();
  }

  Future<void> addToResources(double amount) async {
    if (_prefs == null) return;
    double current = _prefs!.getDouble('${_pfx}available_resources') ?? 0;
    await _prefs!.setDouble('${_pfx}available_resources', current + amount);
    await _loadSettings();
  }

  Future<void> toggleCustomCategory(String category, {bool remove = false}) async {
    if (_prefs == null) return;
    final List<String> current = _settings.customCategories;
    List<String> updated = List<String>.from(current);
    
    if (remove) {
      updated.remove(category);
    } else if (!current.contains(category)) {
      updated.add(category);
    }
    await _prefs!.setStringList('${_pfx}custom_categories', updated);
    await _loadSettings();
  }

  Future<void> addCustomCategory(String category) async {
    await toggleCustomCategory(category, remove: false);
  }

  List<String> get allCategories => ["Shopping", "Food", "Transport", "Bills", "Health", ..._settings.customCategories];
}