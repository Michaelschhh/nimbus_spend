import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/savings_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/apple_button.dart';

class MaturedSavingsScreen extends StatelessWidget {
  const MaturedSavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SavingsProvider>();
    final sProv = context.watch<SettingsProvider>();
    final cur = sProv.settings.currency;
    
    final matured = prov.savings.where((s) => s.isMatured).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Matured Vault", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildTotalMatured(matured.fold(0.0, (sum, s) => sum + s.amount), cur),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Text("MATURED GOALS", style: TextStyle(color: AppColors.textDim, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const Spacer(),
                Text("${matured.length} Items", style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: matured.isEmpty
                ? const Center(child: Text("No matured wealth yet", style: TextStyle(color: AppColors.textDim)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    itemCount: matured.length,
                    itemBuilder: (context, index) {
                      final s = matured[index];
                      return _maturedCard(context, s, cur, prov, sProv);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalMatured(double total, String cur) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.glassBorder),
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Text("Available to Release", style: TextStyle(color: AppColors.textDim, fontSize: 14)),
          const SizedBox(height: 8),
          Text(Formatters.currency(total, cur), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _maturedCard(BuildContext context, dynamic s, String cur, SavingsProvider prov, SettingsProvider sProv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.archive, color: AppColors.success, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(s.description, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
              Text(Formatters.currency(s.amount, cur), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          AppleButton(
            label: "Release Funds to Resources",
            onTap: () => _showReleaseDialog(context, s, prov, sProv),
            bgColor: Colors.white,
            textColor: Colors.black,
          ),
        ],
      ),
    );
  }

  void _showReleaseDialog(BuildContext context, dynamic s, SavingsProvider prov, SettingsProvider sProv) {
    final ctrl = TextEditingController(text: s.amount.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Release Matured Funds", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Specify the amount to transfer to your available resources.", style: TextStyle(color: AppColors.textDim, fontSize: 13)),
            const SizedBox(height: 20),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              double val = double.tryParse(ctrl.text) ?? 0;
              if (val > 0 && val <= s.amount) {
                prov.releaseMaturedFunds(s.id, val, sProv);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Release Now", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
