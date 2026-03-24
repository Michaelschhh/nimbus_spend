import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/settings_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/common/apple_button.dart';
import '../../services/biometric_service.dart';
import 'paywall_screen.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _isEnabled = false;
  String _type = 'passcode';
  final _codeController = TextEditingController();
  bool _isEditing = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsProvider>().settings;
    _isEnabled = s.appLockEnabled;
    _type = s.appLockType;
    _codeController.text = s.appLockCode;
    _biometricEnabled = s.biometricEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final sProv = context.watch<SettingsProvider>();
    final isUnlocked = sProv.isSecurityUnlockedIAP();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Security Lock", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUnlocked)
              _buildLockedBanner(context),
            
            const SizedBox(height: 20),
            _buildToggleTile(context, isUnlocked),
            
            if (_isEnabled && isUnlocked) ...[
              const SizedBox(height: 30),
              const Text("LOCK TYPE", style: TextStyle(color: AppColors.textDim, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildTypeSelector(context),
              
              const SizedBox(height: 30),
              Text(_type == 'passcode' ? "PASSCODE (4-6 DIGITS)" : "PASSWORD", 
                style: const TextStyle(color: AppColors.textDim, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildCodeInput(context),

              const SizedBox(height: 30),
              _buildBiometricToggle(context),
              
              const SizedBox(height: 40),
              AppleButton(
                label: "Save Security Settings",
                onTap: () {
                  if (_codeController.text.isEmpty) return;
                  sProv.updateSecuritySettings(_isEnabled, _type, _codeController.text);
                  sProv.setBiometric(_biometricEnabled);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Security settings updated!"))
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLockedBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.lock, color: Theme.of(context).primaryColor, size: 32),
          const SizedBox(height: 12),
          const Text("Premium Security", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            "Secure your financial data with a passcode, password, fingerprint, or face unlock. This feature requires a one-time purchase or Pro status.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textDim, fontSize: 14),
          ),
          const SizedBox(height: 15),
          AppleButton(
            label: "Unlock for \$1.00",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const PaywallScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile(BuildContext context, bool isUnlocked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(LucideIcons.shieldCheck, color: Theme.of(context).primaryColor),
              const SizedBox(width: 15),
              const Text("Enable App Lock", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          Switch.adaptive(
            value: _isEnabled,
            activeColor: Theme.of(context).primaryColor,
            onChanged: isUnlocked ? (val) {
              setState(() => _isEnabled = val);
              if (!val) {
                context.read<SettingsProvider>().updateSecuritySettings(false, _type, _codeController.text);
              }
            } : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _typeTile("Passcode", LucideIcons.hash, _type == 'passcode'),
          Divider(height: 1, indent: 60, color: Colors.grey.withOpacity(0.1)),
          _typeTile("Password", LucideIcons.key, _type == 'password'),
        ],
      ),
    );
  }

  Widget _typeTile(String label, IconData icon, bool selected) {
    return ListTile(
      leading: Icon(icon, color: selected ? Theme.of(context).primaryColor : AppColors.textDim),
      title: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      trailing: selected ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
      onTap: () => setState(() => _type = label.toLowerCase()),
    );
  }

  Widget _buildCodeInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _codeController,
        obscureText: true,
        keyboardType: _type == 'passcode' ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: _type == 'passcode' ? "Enter 4-6 digits" : "Enter password",
        ),
      ),
    );
  }

  Widget _buildBiometricToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.fingerprint, color: Theme.of(context).primaryColor),
          const SizedBox(width: 15),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Biometric Unlock", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Text(
                "Use fingerprint or face to unlock",
                style: const TextStyle(color: AppColors.textDim, fontSize: 11),
              ),
            ],
          )),
          Switch.adaptive(
            value: _biometricEnabled,
            activeColor: Theme.of(context).primaryColor,
            onChanged: (val) async {
              if (val) {
                final available = await BiometricService.isAvailable();
                if (!available) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No biometrics enrolled on this device. Set up fingerprint or face unlock in your device settings.')),
                    );
                  }
                  return;
                }
                final authed = await BiometricService.authenticate(reason: 'Verify your identity to enable biometric unlock');
                if (!authed) return;
              }
              setState(() => _biometricEnabled = val);
            },
          ),
        ],
      ),
    );
  }
}
