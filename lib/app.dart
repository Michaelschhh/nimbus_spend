import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import 'utils/responsive.dart'; // Added by user instruction

// Screen Imports
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/hub/financial_hub_screen.dart';
import 'screens/onboarding/tos_screen.dart';

// Logic & Theme
import 'providers/settings_provider.dart';
import 'theme/colors.dart';
import 'services/sound_service.dart';
import 'services/haptic_service.dart';
import 'widgets/common/auth_overlay.dart';
import 'widgets/common/nimbus_mascot.dart';
import 'widgets/common/tutorial_overlay.dart';
import 'package:home_widget/home_widget.dart';
import 'widgets/forms/add_expense_form.dart';

class NimbusSpendApp extends StatelessWidget {
  const NimbusSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, setProv, _) {
        final themeIndex = setProv.settings.themeIndex;
        final isDark = setProv.settings.isDarkMode;
        
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nimbus Spend',
          theme: isDark ? _buildDarkTheme(themeIndex) : _buildLightTheme(themeIndex),
          home: setProv.isInitializing
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : setProv.settings.onboardingComplete 
                  ? const MainNavigation() 
                  : const OnboardingScreen(),
        );
      },
    );
  }

  ThemeData _buildDarkTheme(int index) {
    final colors = _getThemeColors(index);
    final bgColor = _getDarkBgColor(index);
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgColor,
      cardColor: Color.alphaBlend(Colors.white.withOpacity(0.05), bgColor),
      primaryColor: colors.primary,
      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        secondary: colors.secondary,
        surface: Color.alphaBlend(Colors.white.withOpacity(0.05), bgColor),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.primary,
        selectionColor: colors.primary.withOpacity(0.3),
        selectionHandleColor: colors.primary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.selected) ? colors.primary : null),
        trackColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.selected) ? colors.primary.withOpacity(0.5) : null),
        trackOutlineColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.selected) ? Colors.transparent : null),
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
      useMaterial3: true,
    );
  }

  ThemeData _buildLightTheme(int index) {
    final colors = _getThemeColors(index);
    final bgColor = _getLightBgColor(index);
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgColor,
      cardColor: Color.alphaBlend(Colors.black.withOpacity(0.03), bgColor),
      primaryColor: colors.primary,
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        secondary: colors.secondary,
        surface: Color.alphaBlend(Colors.black.withOpacity(0.03), bgColor),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.primary,
        selectionColor: colors.primary.withOpacity(0.3),
        selectionHandleColor: colors.primary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.selected) ? colors.primary : null),
        trackColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.selected) ? colors.primary.withOpacity(0.5) : null),
        trackOutlineColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.selected) ? Colors.transparent : null),
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
      useMaterial3: true,
    );
  }

  _ThemeColors _getThemeColors(int index) {
    switch (index) {
      case 0: // Default — Apple Blue
        return _ThemeColors(
          primary: const Color(0xFF0A84FF),
          secondary: const Color(0xFF5AC8FA),
        );
      case 1: // Emerald Night
        return _ThemeColors(
          primary: const Color(0xFF10BB7C), // Slightly more vibrant green
          secondary: const Color(0xFF34D399),
        );
      case 2: // Ocean Blue
        return _ThemeColors(
          primary: const Color(0xFF2563EB),
          secondary: const Color(0xFF60A5FA),
        );
      case 3: // Midnight Steel
        return _ThemeColors(
          primary: const Color(0xFF64748B),
          secondary: const Color(0xFF94A3B8),
        );
      case 4: // Cherry Blossom
        return _ThemeColors(
          primary: const Color(0xFFDB2777),
          secondary: const Color(0xFFFB7185),
        );
      case 5: // Obsidian
        return _ThemeColors(
          primary: const Color(0xFF334155),
          secondary: const Color(0xFF475569),
        );
      case 6: // Sunburst
        return _ThemeColors(
          primary: const Color(0xFFD97706),
          secondary: const Color(0xFFF59E0B),
        );
      case 7: // Forest
        return _ThemeColors(
          primary: const Color(0xFF059669),
          secondary: const Color(0xFF10B981),
        );
      case 8: // Lavender
        return _ThemeColors(
          primary: const Color(0xFF7C3AED),
          secondary: const Color(0xFFA78BFA),
        );
      case 9: // Rose Gold
        return _ThemeColors(
          primary: const Color(0xFFBE185D),
          secondary: const Color(0xFFF472B6),
        );
      default:
        return _ThemeColors(
          primary: const Color(0xFF0A84FF),
          secondary: const Color(0xFF5AC8FA),
        );
    }
  }

  Color _getDarkBgColor(int index) {
    switch (index) {
      case 0: return Colors.black;
      case 1: return const Color(0xFF062016); // Deep Emerald
      case 2: return const Color(0xFF06152B); // Deep Navy
      case 3: return const Color(0xFF0F172A); // Slate Black
      case 4: return const Color(0xFF210B13); // Deep Cherry
      case 5: return const Color(0xFF121212); // Pure Obsidian
      case 6: return const Color(0xFF1E1402); // Deep Amber
      case 7: return const Color(0xFF021E14); // Deep Forest
      case 8: return const Color(0xFF14021E); // Deep Lavender
      case 9: return const Color(0xFF1E020D); // Deep Rose
      default: return Colors.black;
    }
  }

  Color _getLightBgColor(int index) {
    switch (index) {
      case 0: return Colors.white;
      case 1: return const Color(0xFFF0FDF4); // Minty white
      case 2: return const Color(0xFFEFF6FF); // Blue white
      case 3: return const Color(0xFFF8FAFC); // Slate white
      case 4: return const Color(0xFFFFF1F2); // Rose white
      case 5: return const Color(0xFFF1F5F9); // Slate Gray white
      case 6: return const Color(0xFFFFFBEB); // Amber white
      case 7: return const Color(0xFFECFDF5); // Emerald white
      case 8: return const Color(0xFFF5F3FF); // Violet white
      case 9: return const Color(0xFFFDF2F8); // Pink white
      default: return Colors.white;
    }
  }
}

class _ThemeColors {
  final Color primary;
  final Color secondary;
  _ThemeColors({required this.primary, required this.secondary});
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sProv = context.read<SettingsProvider>();
      SoundService.setEnabled(sProv.settings.soundsEnabled);
      
      Future.delayed(const Duration(milliseconds: 500), () {
        SoundService.welcome();
      });

      HomeWidget.widgetClicked.listen((Uri? uri) {
        if (!mounted) return;
        if (uri != null && uri.host == 'add_expense') {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => const AddExpenseForm(),
          );
        }
      });

      HomeWidget.initiallyLaunchedFromHomeWidget().then((Uri? uri) {
        if (!mounted) return;
        if (uri != null && uri.host == 'add_expense') {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => const AddExpenseForm(),
          );
        }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final s = setProv.settings;
    
    return Scaffold(
      extendBody: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notif) {
          if (notif is ScrollUpdateNotification || notif is UserScrollNotification) {
            NimbusMascot.mascotKey.currentState?.onUserScroll();
          }
          return false;
        },
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            final s = setProv.settings;
            if (s.mascotEnabled && (s.isPro || s.adsRemoved)) {
              NimbusMascot.mascotKey.currentState?.tapAt(event.position);
            }
          },
          child: Stack(
            children: [
            setProv.settings.tosAccepted 
              ? (setProv.settings.tutorialSeen 
                  ? IndexedStack(
                      index: _index,
                      children: _pages,
                    )
                  : TutorialOverlay(onComplete: () => setProv.completeTutorial()))
              : TermsOfServiceScreen(onAccept: () => setProv.acceptTOS()),
          
          // Nimbus Mascot Overlay
          if (s.mascotEnabled && (s.isPro || s.adsRemoved))
            NimbusMascot(key: NimbusMascot.mascotKey),

          // Security Lock Overlay
          if (s.appLockEnabled && !s.securityUnlocked)
            AuthOverlay(),

          // The Floating Nav Bar
          if (setProv.settings.tosAccepted && setProv.settings.tutorialSeen && (!s.appLockEnabled || s.securityUnlocked))
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildAppleNavBar(isDark),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildAppleNavBar(bool isDark) {
    final primaryColor = Theme.of(context).primaryColor;
    final s = context.watch<SettingsProvider>().settings;

    
    return LayoutBuilder(builder: (context, constraints) {
      double maxWidth = constraints.maxWidth * 0.9;
      double itemWidth = maxWidth / 5;
      final bottomPadding = MediaQuery.of(context).padding.bottom;
      final navHeight = 70.0; // Consistently sized visually grounded island
      
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: maxWidth,
          margin: EdgeInsets.only(
            bottom: (Responsive.isTablet(context) ? 24.0 : 16.0) + bottomPadding,
          ),
        height: navHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(navHeight / 2),
          border: Border.all(
            color: isDark 
                ? Colors.white.withOpacity(0.08) 
                : Colors.black.withOpacity(0.06),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(navHeight / 2),
          child: s.performanceModeEnabled 
            ? Stack(
                alignment: Alignment.center,
                children: _buildNavStack(primaryColor, itemWidth, navHeight, isDark),
              )
            : BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Stack(
                  alignment: Alignment.center,
                  children: _buildNavStack(primaryColor, itemWidth, navHeight, isDark),
                ),
              ),
        ),
        ),
      );
    });
  }


  List<Widget> _buildNavStack(Color primaryColor, double itemWidth, double navHeight, bool isDark) {
    return [
      // THE SLIDING PILL
      AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        left: _index * itemWidth,
        top: 0,
        bottom: 0,
        child: SizedBox(
          width: itemWidth,
          child: Center(
            child: Container(
              width: Responsive.isTablet(context) ? 64 : Responsive.sp(56, context),
              height: Responsive.isTablet(context) ? 42 : 36, // Guarantees a horizontal pill shape
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.2),
                    primaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 10,
                )
              ],
            ),
          ),
        ),
      ),
      ),
      
      // THE INTERACTIVE ICONS
      Row(
        children: List.generate(5, (i) => Expanded(
          child: GestureDetector(
            onTap: () {
              SoundService.tap();
              HapticService.light();
              setState(() => _index = i);
            },
            behavior: HitTestBehavior.opaque,
            child: Icon(
              _getIcon(i),
              color: _index == i ? primaryColor : AppColors.textDim,
              size: Responsive.sp(23, context),
            ),
          ),
        )),
      ),
    ];
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