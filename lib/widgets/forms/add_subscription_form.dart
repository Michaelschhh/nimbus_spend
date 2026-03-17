import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/subscription.dart';
import '../../providers/subscription_provider.dart';
import '../../theme/colors.dart';

class AddSubscriptionForm extends StatefulWidget {
  const AddSubscriptionForm({super.key});

  @override
  State<AddSubscriptionForm> createState() => _AddSubscriptionFormState();
}

class _AddSubscriptionFormState extends State<AddSubscriptionForm> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedFrequency = 'Monthly';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24, left: 24, right: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Add Recurring Payment",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          _field(_nameController, "Service Name (e.g. Netflix)", LucideIcons.tv),
          const SizedBox(height: 15),
          _field(_amountController, "Amount", LucideIcons.banknote, isNum: true),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            value: _selectedFrequency,
            dropdownColor: AppColors.cardBg,
            style: const TextStyle(color: Colors.white),
            items: ['Weekly', 'Monthly', 'Yearly']
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (v) => setState(() => _selectedFrequency = v!),
            decoration: InputDecoration(
              labelText: "Frequency",
              labelStyle: const TextStyle(color: AppColors.textDim),
              prefixIcon: const Icon(LucideIcons.calendar, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.white24)),
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity, height: 55,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Track Subscription",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String hint, IconData icon, {bool isNum = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: AppColors.textDim),
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.white24)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors.primary)),
      ),
    );
  }

  void _save() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (_nameController.text.isEmpty || amount <= 0) return;

    final sub = Subscription(
      name: _nameController.text,
      amount: amount,
      category: 'Bills 📄',
      startDate: DateTime.now(),
      frequency: _selectedFrequency,
      nextDueDate: DateTime.now().add(const Duration(days: 30)),
    );

    context.read<SubscriptionProvider>().addSubscription(sub);
    Navigator.pop(context);
  }
}
