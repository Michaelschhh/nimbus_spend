import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  AppSettings _settings = AppSettings(
    name: 'User', currency: 'USD', monthlyBudget: 1000, 
    hourlyWage: 20, availableResources: 0
  );

  AppSettings get settings => _settings;
  SettingsProvider();

  Future<void> init() async {
    await _loadSettings(initial: true);
  }

  Future<void> updateSalarySettings(bool enabled, double amount, String frequency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_salary_earner', enabled);
    await prefs.setDouble('salary_amount', amount);
    await prefs.setString('salary_frequency', frequency);
    await _loadSettings();
  }

  Future<void> _loadSettings({bool initial = false}) async {
    if (initial) {
      _isInitializing = true;
      notifyListeners();
    }
    final prefs = await SharedPreferences.getInstance();
    _settings = AppSettings(
      name: prefs.getString('user_name') ?? 'User',
      currency: prefs.getString('currency') ?? 'USD',
      monthlyBudget: prefs.getDouble('monthly_budget') ?? 1000,
      hourlyWage: prefs.getDouble('hourly_wage') ?? 20,
      availableResources: prefs.getDouble('available_resources') ?? 0,
      onboardingComplete: prefs.getBool('onboarding_complete') ?? false,
      soundsEnabled: prefs.getBool('sounds_enabled') ?? true,
      isPro: prefs.getBool('is_pro') ?? false,
      tosAccepted: prefs.getBool('tos_accepted') ?? false,
      tutorialSeen: prefs.getBool('tutorial_seen') ?? false,
      isSalaryEarner: prefs.getBool('is_salary_earner') ?? false,
      salaryAmount: prefs.getDouble('salary_amount') ?? 0.0,
      salaryFrequency: prefs.getString('salary_frequency') ?? 'Monthly',
      isDarkMode: prefs.getBool('is_dark_mode') ?? true,
      themeIndex: prefs.getInt('theme_index') ?? 0,
      themesUnlocked: prefs.getBool('themes_unlocked') ?? false,
      themeExpiryTimestamp: prefs.getInt('theme_expiry_timestamp'),
      adsRemoved: prefs.getBool('ads_removed') ?? false,
      performanceModeEnabled: prefs.getBool('performance_mode_enabled') ?? false,


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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_lock_enabled', enabled);
    await prefs.setString('app_lock_type', type);
    await prefs.setString('app_lock_code', code);
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_pro', true);
    await prefs.setBool('ads_removed', true);
    await prefs.setBool('themes_unlocked', true);
    await prefs.setBool('security_unlocked_iap', true); // New IAP flag
    await _loadSettings();
  }

  Future<void> removeAds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ads_removed', true);
    await _loadSettings();
  }

  Future<void> updateResources(double delta) async {
    final prefs = await SharedPreferences.getInstance();
    double newValue = _settings.availableResources + delta;
    await prefs.setDouble('available_resources', newValue);
    _settings = _settings.copyWith(availableResources: newValue);
    notifyListeners();
  }

  Future<void> addRolloverFunds(double amount) async {
    await updateResources(amount);
  }

  Future<void> updateProfile(String name, double budget, double wage, String currency) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('user_name', name);
    await prefs.setDouble('monthly_budget', budget);
    await prefs.setDouble('hourly_wage', wage);
    await prefs.setString('currency', currency);
    
    await _loadSettings();
  }

  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
    await _loadSettings();
  }

  Future<void> setThemeIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_index', index);
    await _loadSettings();
  }

  Future<void> setPerformanceMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('performance_mode_enabled', enabled);
    await _loadSettings();
  }

  Future<void> unlockThemes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('themes_unlocked', true);
    await _loadSettings();
  }

  Future<void> unlockSecurity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('security_unlocked_iap', true);
    await _loadSettings();
  }
  
  Future<void> unlockThemeFor24h() async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch;
    await prefs.setInt('theme_expiry_timestamp', expiry);
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mascot_enabled', enabled);
    await _loadSettings();
  }

  Future<void> setMascotTipsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mascot_tips_enabled', enabled);
    await _loadSettings();
  }

  Future<void> completeOnboarding(String name, double budget, double wage, String currency, {double? availableResources, bool? isSalaryEarner, double? salaryAmount}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setDouble('monthly_budget', budget);
    await prefs.setDouble('hourly_wage', wage);
    await prefs.setString('currency', currency);
    
    // Only set available resources on initial setup
    if (!(_settings.onboardingComplete)) {
      await prefs.setDouble('available_resources', availableResources ?? budget);
      
      // Handle salary onboarding
      if (isSalaryEarner != null) {
        await prefs.setBool('is_salary_earner', isSalaryEarner);
        await prefs.setDouble('salary_amount', salaryAmount ?? 0);
        await prefs.setString('salary_frequency', 'Monthly');
      }
      
      await prefs.setBool('onboarding_complete', true);
    }
    await _loadSettings();
  }

  Future<void> acceptTOS() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tos_accepted', true);
    await _loadSettings();
  }

  Future<void> completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_seen', true);
    await _loadSettings();
  }

  Future<void> clearAllData() async {
    // 1. Storage wipe
    await StorageService().clearAll();
    
    // 2. Prefs wipe
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setBool('onboarding_complete', false);
    
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('available_resources', amount);
    await _loadSettings();
  }

  Future<void> deductFromResources(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    double current = prefs.getDouble('available_resources') ?? 0;
    await prefs.setDouble('available_resources', (current - amount).clamp(0, double.infinity));
    await _loadSettings();
  }

  Future<void> addToResources(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    double current = prefs.getDouble('available_resources') ?? 0;
    await prefs.setDouble('available_resources', current + amount);
    await _loadSettings();
  }

  Future<void> toggleSounds(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sounds_enabled', value);
    await _loadSettings();
  }
}