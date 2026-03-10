import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  AppSettings _settings = AppSettings(
    name: 'User', currency: 'USD', monthlyBudget: 1000, 
    hourlyWage: 20, availableResources: 0
  );

  AppSettings get settings => _settings;
  SettingsProvider() { _loadSettings(); }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _settings = AppSettings(
      name: prefs.getString('user_name') ?? 'User',
      currency: prefs.getString('currency') ?? 'USD',
      monthlyBudget: prefs.getDouble('monthly_budget') ?? 1000,
      hourlyWage: prefs.getDouble('hourly_wage') ?? 20,
      availableResources: prefs.getDouble('available_resources') ?? 0,
      onboardingComplete: prefs.getBool('onboarding_complete') ?? false,
    );
    notifyListeners();
  }

  Future<void> updateResources(double delta) async {
    final prefs = await SharedPreferences.getInstance();
    double newValue = _settings.availableResources + delta;
    await prefs.setDouble('available_resources', newValue);
    _settings = _settings.copyWith(availableResources: newValue);
    notifyListeners();
  }

  Future<void> completeOnboarding(String name, double budget, double wage, String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setDouble('monthly_budget', budget);
    await prefs.setDouble('hourly_wage', wage);
    await prefs.setString('currency', currency);
    await prefs.setDouble('available_resources', budget); // First month setup
    await prefs.setBool('onboarding_complete', true);
    await _loadSettings();
  }

  Future<void> clearAllData() async {
    final storage = StorageService();
    final db = await storage.database;
    // Wipe Data
    await db.delete('expenses');
    await db.delete('savings');
    // Wipe Prefs
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Reset App
    await _loadSettings();
  }
}