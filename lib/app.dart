import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';

// Screen Imports
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/savings/savings_screen.dart';
import 'screens/settings/settings_screen.dart';

// Logic & Theme
import 'providers/settings_provider.dart';
import 'theme/colors.dart';
import 'services/sound_service.dart';

class NimbusSpendApp extends StatelessWidget {
  const NimbusSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, setProv, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nimbus Spend',
          // Stable Minimal Theme to prevent compilation errors
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: AppColors.background,
            primaryColor: AppColors.primary,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
            ),
          ),
          // Control Flow: Setup vs Dashboard
          home: setProv.settings.onboardingComplete 
              ? const MainNavigation() 
              : const OnboardingScreen(),
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Play Welcome Sound every time the app opens
    Future.delayed(const Duration(milliseconds: 500), () {
      SoundService.welcome();
    });
  }

  final List<Widget> _pages = [
    const DashboardScreen(),
    const HistoryScreen(),
    const ReportsScreen(),
    const SavingsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows content to flow behind the glass nav bar
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: _buildAppleNavBar(),
    );
  }

  Widget _buildAppleNavBar() {
    return LayoutBuilder(builder: (context, constraints) {
      // DYNAMIC MATH:
      // Total Screen Width - (Margin 24 * 2) = Inner Nav Width
      // Inner Nav Width / 5 = Exact Width per icon
      double totalNavWidth = constraints.maxWidth - 48;
      double itemWidth = totalNavWidth / 5;

      return Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
        height: 75,
        decoration: BoxDecoration(
          color: AppColors.cardBg.withOpacity(0.92),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // THE SLIDING PILL - Mathematically locked to the icon center
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutQuart,
                  left: _index * itemWidth,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: itemWidth,
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
                
                // THE INTERACTIVE ICONS
                Row(
                  children: List.generate(5, (i) => Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Play the 'pop' sound on every click
                        SoundService.tap();
                        setState(() => _index = i);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Icon(
                        _getIcon(i),
                        color: _index == i ? AppColors.primary : AppColors.textDim,
                        size: 24,
                      ),
                    ),
                  )),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  IconData _getIcon(int i) {
    switch (i) {
      case 0: return LucideIcons.wallet;
      case 1: return LucideIcons.history;
      case 2: return LucideIcons.pieChart;
      case 3: return LucideIcons.target;
      default: return LucideIcons.settings;
    }
  }
}