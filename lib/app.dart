import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

// Screen Imports
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/savings/savings_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/hub/financial_hub_screen.dart';
import 'screens/onboarding/tos_screen.dart';
import 'screens/onboarding/tutorial_screen.dart';

// Logic & Theme
import 'providers/settings_provider.dart';
import 'theme/colors.dart';
import 'services/sound_service.dart';
import 'widgets/common/ad_placements.dart';

class NimbusSpendApp extends StatelessWidget {
  const NimbusSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, setProv, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nimbus Spend',
          theme: FlexThemeData.dark(
            scheme: FlexScheme.deepPurple,
            surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
            blendLevel: 15,
            appBarStyle: FlexAppBarStyle.background,
            appBarOpacity: 0.90,
            subThemesData: const FlexSubThemesData(
              blendOnLevel: 30,
            ),
            useMaterial3ErrorColors: true,
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            useMaterial3: true,
            fontFamily: GoogleFonts.inter().fontFamily,
          ),
          // Control Flow: Setup vs Dashboard
          home: setProv.isInitializing
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : setProv.settings.onboardingComplete 
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
    // Sync sound settings and play welcome sound
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sProv = context.read<SettingsProvider>();
      SoundService.setEnabled(sProv.settings.soundsEnabled);
      
      Future.delayed(const Duration(milliseconds: 500), () {
        SoundService.welcome();
      });
    });
  }

  final List<Widget> _pages = [
    const DashboardScreen(),
    const HistoryScreen(),
    const ReportsScreen(),
    const FinancialHubScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final setProv = context.watch<SettingsProvider>();
    return Scaffold(
      extendBody: true, // Allows content to flow behind the glass nav bar
      backgroundColor: AppColors.background,
      body: setProv.settings.tosAccepted 
        ? (setProv.settings.tutorialSeen 
            ? IndexedStack(
                index: _index,
                children: _pages,
              )
            : TutorialOverlay(onComplete: () => setProv.completeTutorial()))
        : TermsOfServiceScreen(onAccept: () => setProv.acceptTOS()),
      bottomNavigationBar: (setProv.settings.tosAccepted && setProv.settings.tutorialSeen) 
        ? _buildAppleNavBar() 
        : null,
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
          // LIQUID GLASS: More transparent, more blur, subtle gradient
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: -5,
              offset: const Offset(0, 15),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            // DEEPER BLUR for that liquid feel
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // THE SLIDING PILL - Liquid highlight
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  left: _index * itemWidth,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: itemWidth,
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.2),
                            AppColors.primary.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 10,
                          )
                        ],
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
      case 3: return LucideIcons.briefcase;
      default: return LucideIcons.settings;
    }
  }
}