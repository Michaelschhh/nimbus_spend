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
    await _loadSettings();
  }

  Future<void> updateSalarySettings(bool enabled, double amount, String frequency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_salary_earner', enabled);
    await prefs.setDouble('salary_amount', amount);
    await prefs.setString('salary_frequency', frequency);
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    _isInitializing = true;
    notifyListeners();
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
    );
    _isInitializing = false;
    notifyListeners();
  }

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
    
    // Calculate the budget delta and adjust available resources
    double oldBudget = _settings.monthlyBudget;
    double delta = budget - oldBudget;
    
    await prefs.setString('user_name', name);
    await prefs.setDouble('monthly_budget', budget);
    await prefs.setDouble('hourly_wage', wage);
    await prefs.setString('currency', currency);
    
    // Adjust available resources by the budget change
    if (delta != 0) {
      double currentResources = prefs.getDouble('available_resources') ?? 0;
      await prefs.setDouble('available_resources', currentResources + delta);
    }
    
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