import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'providers/account_provider.dart';
import 'providers/income_provider.dart';
import 'providers/shopping_provider.dart';

import 'services/ad_service.dart';
import 'services/iap_service.dart';
import 'services/notification_service.dart';
import 'services/haptic_service.dart';
import 'services/sound_service.dart';
import 'services/recurring_service.dart';
import 'services/widget_service.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

// Background alarm callback — runs even when the app is dead or after reboot.
@pragma('vm:entry-point')
void backgroundAlarmCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
}

void main() async {
  // Ensure Flutter engine is connected
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge: make system nav bar transparent
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarColor: Colors.transparent,
  ));

  // Initialize Core Infrastructure
  await NotificationService.init(); 
  await AdService.init();
  await IAPService.init();
  await HapticService.init();
  await SoundService.init();

  // Request notification permission moved to LogicInitializer

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
        ChangeNotifierProvider(create: (_) => AccountProvider()..fetchAccounts()),
        ChangeNotifierProvider(create: (_) => IncomeProvider()..fetchIncomes()),
        ChangeNotifierProvider(create: (_) => ShoppingProvider()..fetchLists()),
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

class _LogicInitializerState extends State<LogicInitializer> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initLogic();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkCycles();
    }
  }

  Future<void> _checkCycles() async {
    final sProv = Provider.of<SettingsProvider>(context, listen: false);
    final eProv = Provider.of<ExpenseProvider>(context, listen: false);
    final bProv = Provider.of<BillsProvider>(context, listen: false);
    final dProv = Provider.of<DebtProvider>(context, listen: false);
    final subProv = Provider.of<SubscriptionProvider>(context, listen: false);
    final prov = Provider.of<SavingsProvider>(context, listen: false);
    
    await RecurringService.checkAllCycles(sProv, eProv, bProv, dProv, subProv, prov);

    // Refresh home screen widget with real data
    WidgetService.updateWidgetData(
      balance: sProv.settings.availableResources,
      spentToday: eProv.totalSpentToday,
      currency: sProv.settings.currency,
    );
  }

  void _initLogic() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final sProv = Provider.of<SettingsProvider>(context, listen: false);
      final eProv = Provider.of<ExpenseProvider>(context, listen: false);
      final bProv = Provider.of<BillsProvider>(context, listen: false);
      final dProv = Provider.of<DebtProvider>(context, listen: false);
      final subProv = Provider.of<SubscriptionProvider>(context, listen: false);
      
      // Wire IAP callback
      IAPService.onPurchaseSuccess = (String productId) {
        if (productId == IAPService.removeAdsProductId) {
          sProv.removeAds();
        } else if (productId == IAPService.unlockThemesProductId) {
          sProv.unlockThemes();
        } else if (productId == 'unlock_security') {
          sProv.unlockSecurity();
        } else if (productId == IAPService.bundleProProductId) {
          sProv.upgradeToPro();
          sProv.unlockThemes();
        }
      };
      
      // Await data load before checking cycles
      await sProv.init();
      await eProv.fetchExpenses();
      await bProv.fetchBills();
      await dProv.fetchDebts();
      await subProv.fetchSubscriptions();
      await Provider.of<AccountProvider>(context, listen: false).fetchAccounts();
      await Provider.of<IncomeProvider>(context, listen: false).fetchIncomes();
      await Provider.of<ShoppingProvider>(context, listen: false).fetchLists();
      final prov = Provider.of<SavingsProvider>(context, listen: false);
      await prov.fetchSavings();
      
      // Perform automated checks for month rollover and recurring payments
      await _checkCycles();

      // Request notification permission late so UI context exists
      await NotificationService.requestPermission();

      // Initialize background alarm (non-blocking, after app is running)
      try {
        await AndroidAlarmManager.initialize();
        await AndroidAlarmManager.periodic(
          const Duration(minutes: 15),
          0,
          backgroundAlarmCallback,
          exact: true,
          wakeup: true,
          rescheduleOnReboot: true,
        );
      } catch (e) {
        debugPrint('AlarmManager init failed (non-critical): $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}