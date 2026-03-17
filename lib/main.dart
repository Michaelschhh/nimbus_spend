import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/settings_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/savings_provider.dart';
import 'providers/gamification_provider.dart';
import 'providers/bills_provider.dart';
import 'providers/debt_provider.dart';
import 'providers/goals_provider.dart';
import 'providers/subscription_provider.dart';

import 'services/ad_service.dart';
import 'services/notification_service.dart';
import 'services/haptic_service.dart';
import 'services/sound_service.dart';
import 'services/recurring_service.dart';

void main() async {
  // Ensure Flutter engine is connected
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Core Infrastructure
  // All these methods now exist in their respective service files
  await NotificationService.init(); 
  await AdService.init();
  await HapticService.init();
  await SoundService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => SavingsProvider()..fetchSavings()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()..fetchSubscriptions()),
        ChangeNotifierProvider(create: (_) => GamificationProvider()),
        ChangeNotifierProvider(create: (_) => GoalsProvider()..fetchGoals()),
        ChangeNotifierProvider(create: (_) => BillsProvider()..fetchBills()),
        ChangeNotifierProvider(create: (_) => DebtProvider()..fetchDebts()),
      ],
      child: const LogicInitializer(child: NimbusSpendApp()),
    ),
  );
}

class LogicInitializer extends StatefulWidget {
  final Widget child;
  const LogicInitializer({super.key, required this.child});

  @override
  State<LogicInitializer> createState() => _LogicInitializerState();
}

class _LogicInitializerState extends State<LogicInitializer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final sProv = Provider.of<SettingsProvider>(context, listen: false);
      final eProv = Provider.of<ExpenseProvider>(context, listen: false);
      
      // Await data load before checking cycles
      await sProv.init();
      await eProv.fetchExpenses();
      
      // Perform automated checks for month rollover and recurring payments
      await RecurringService.checkAllCycles(sProv, eProv);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}