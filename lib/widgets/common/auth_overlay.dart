import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../providers/settings_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/common/apple_button.dart';
import '../../services/biometric_service.dart';
import '../../services/shader_service.dart';

class AuthOverlay extends StatefulWidget {
  const AuthOverlay({super.key});

  @override
  State<AuthOverlay> createState() => _AuthOverlayState();
}

class _AuthOverlayState extends State<AuthOverlay> {
  final _controller = TextEditingController();
  String _error = '';
  bool _biometricAttempted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometric();
    });
  }

  Future<void> _tryBiometric() async {
    final s = context.read<SettingsProvider>().settings;
    if (!s.biometricEnabled || _biometricAttempted) return;
    _biometricAttempted = true;

    final available = await BiometricService.isAvailable();
    if (!available) return;

    final success = await BiometricService.authenticate();
    if (success && mounted) {
      context.read<SettingsProvider>().setSecurityUnlocked(true);
    }
  }

  void _verify() {
    final s = context.read<SettingsProvider>().settings;
    if (_controller.text == s.appLockCode) {
      context.read<SettingsProvider>().setSecurityUnlocked(true);
    } else {
      setState(() {
        _error = "Incorrect ${_controller.text.isNotEmpty ? s.appLockType : 'code'}";
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>().settings;
    final isWater = s.themeIndex == 10;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = Container(
      color: isWater ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            s.biometricEnabled ? LucideIcons.fingerprint : LucideIcons.lock, 
            size: 60, 
            color: isWater ? (isDark ? Colors.white : Colors.black) : Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 24),
          Text("Nimbus Secure", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isWater ? (isDark ? Colors.white : Colors.black) : null)),
          const SizedBox(height: 8),
          Text(
            s.biometricEnabled
                ? "Use biometrics or enter your ${s.appLockType} to unlock"
                : s.appLockType == 'passcode' 
                    ? "Enter your passcode to unlock" 
                    : "Enter your password to unlock",
            style: TextStyle(color: isWater ? (isDark ? Colors.white70 : Colors.black87) : AppColors.textDim),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          TextField(
            controller: _controller,
            obscureText: true,
            textAlign: TextAlign.center,
            autofocus: !s.biometricEnabled,
            keyboardType: s.appLockType == 'passcode' ? TextInputType.number : TextInputType.text,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8, color: isWater ? (isDark ? Colors.white : Colors.black) : null),
            decoration: InputDecoration(
              hintText: s.appLockType == 'passcode' ? "••••" : "Password",
              hintStyle: TextStyle(letterSpacing: 4, color: isWater ? (isDark ? Colors.white54 : Colors.black54) : null),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: isWater ? (isDark ? Colors.white30 : Colors.black26) : Theme.of(context).primaryColor.withOpacity(0.3))),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: isWater ? (isDark ? Colors.white : Colors.black) : Theme.of(context).primaryColor, width: 2)),
            ),
            onSubmitted: (_) => _verify(),
          ),
          
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(_error, style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
          
          const SizedBox(height: 40),
          AppleButton(
            label: "Unlock",
            bgColor: isWater ? (isDark ? Colors.white : Colors.black) : null,
            textColor: isWater ? (isDark ? Colors.black : Colors.white) : null,
            onTap: _verify,
          ),
          
          if (s.biometricEnabled) ...[
            const SizedBox(height: 16),
            AppleButton(
              label: "Use Biometrics",
              bgColor: isWater ? (isDark ? Colors.white12 : Colors.black12) : Theme.of(context).primaryColor.withOpacity(0.15),
              textColor: isWater ? (isDark ? Colors.white : Colors.black) : Theme.of(context).primaryColor,
              onTap: () {
                _biometricAttempted = false;
                _tryBiometric();
              },
            ),
          ],
          
          const SizedBox(height: 20),
        ],
      ),
    );

    if (isWater) {
      final filter = ShaderService.getLiquidGlassFilter(intensity: 0.1, blurAmt: 60.0);
      content = BackdropFilter(
        filter: filter ?? ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          color: (isDark ? Colors.black : Colors.white).withOpacity(0.2),
          child: content,
        ),
      );
    }

    return content;
  }
}
