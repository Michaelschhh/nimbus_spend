import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/subscription.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense.dart';
import '../../theme/colors.dart';
import '../common/custom_switch.dart';
import '../../utils/life_cost_utils.dart';
import '../../services/ad_service.dart';
import '../common/apple_button.dart';

class AddSubscriptionForm extends StatefulWidget {
  final Subscription? existingSubscription;
  const AddSubscriptionForm({super.key, this.existingSubscription});

  @override
  State<AddSubscriptionForm> createState() => _AddSubscriptionFormState();
}

class _AddSubscriptionFormState extends State<AddSubscriptionForm> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _billingDayController = TextEditingController();
  String _selectedFrequency = 'Monthly';
  bool _chargeFirstInterval = false;
  String _routing = 'allowance';

  @override
  void initState() {
    super.initState();
    if (widget.existingSubscription != null) {
      _nameController.text = widget.existingSubscription!.name;
      _amountController.text = widget.existingSubscription!.amount.toString();
      _billingDayController.text = widget.existingSubscription!.billingDay?.toString() ?? '';
      if (['Weekly', 'Monthly', 'Yearly'].contains(widget.existingSubscription!.frequency)) {
        _selectedFrequency = widget.existingSubscription!.frequency;
      }
      _chargeFirstInterval = widget.existingSubscription!.chargeFirstInterval;
      _routing = widget.existingSubscription!.defaultRouting;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24, left: 24, right: 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.existingSubscription == null ? "Add Recurring Payment" : "Edit Subscription",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))),
          const SizedBox(height: 20),
          _field(_nameController, "Service Name (e.g. Netflix)", LucideIcons.tv),
          const SizedBox(height: 15),
          _field(_amountController, "Amount", LucideIcons.banknote, isNum: true),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            initialValue: _selectedFrequency,
            dropdownColor: Theme.of(context).cardColor,
            style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
            items: ['Weekly', 'Monthly', 'Yearly']
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (v) => setState(() => _selectedFrequency = v!),
            decoration: InputDecoration(
              labelText: "Frequency",
              labelStyle: const TextStyle(color: AppColors.textDim),
              prefixIcon: Icon(LucideIcons.calendar, color: Theme.of(context).primaryColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26))),
            ),
          ),
          if (_selectedFrequency == 'Monthly') ...[
            const SizedBox(height: 15),
            _field(_billingDayController, "Billing Day (1-31) (Optional)", LucideIcons.calendarClock, isNum: true),
          ],
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Charge first interval immediately?", style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontSize: 14)),
              CustomSwitch(
                value: _chargeFirstInterval, 
                onChanged: (v) => setState(() => _chargeFirstInterval = v),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text("Default Funding Source", style: TextStyle(color: AppColors.textDim, fontSize: 11)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _routing,
            dropdownColor: Theme.of(context).cardColor,
            style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
            decoration: InputDecoration(
              prefixIcon: Icon(LucideIcons.wallet, color: Theme.of(context).primaryColor, size: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26))),
            ),
            items: const [
              DropdownMenuItem(value: 'allowance', child: Text("Monthly Budget")),
              DropdownMenuItem(value: 'resources', child: Text("Available Resources")),
              DropdownMenuItem(value: 'none', child: Text("None (Track Only)")),
            ],
            onChanged: (v) => setState(() => _routing = v!),
          ),
          const SizedBox(height: 25),
          AppleButton(
            label: widget.existingSubscription == null ? "Track Subscription" : "Save Changes",
            onTap: _save,
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String hint, IconData icon, {bool isNum = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      textCapitalization: isNum ? TextCapitalization.none : TextCapitalization.sentences,
      style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: AppColors.textDim),
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Theme.of(context).primaryColor)),
      ),
    );
  }

  void _save() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (_nameController.text.isEmpty || amount <= 0) return;

    int? billingDay;
    if (_selectedFrequency == 'Monthly') {
      billingDay = int.tryParse(_billingDayController.text);
      if (billingDay != null && (billingDay < 1 || billingDay > 31)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Billing day must be between 1 and 31', style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))), backgroundColor: AppColors.danger)
        );
        return;
      }
    }

    if (widget.existingSubscription != null) {
      final sub = Subscription(
        id: widget.existingSubscription!.id,
        name: _nameController.text,
        amount: amount,
        category: widget.existingSubscription!.category,
        startDate: widget.existingSubscription!.startDate,
        frequency: _selectedFrequency,
        nextDueDate: widget.existingSubscription!.nextDueDate,
        isActive: widget.existingSubscription!.isActive,
        billingDay: billingDay,
        chargeFirstInterval: _chargeFirstInterval,
        defaultRouting: _routing,
      );
      context.read<SubscriptionProvider>().updateSubscription(sub);
    } else {
      DateTime nextDue = DateTime.now().add(const Duration(days: 30));
      if (_selectedFrequency == 'Weekly') nextDue = DateTime.now().add(const Duration(days: 7));
      if (_selectedFrequency == 'Yearly') nextDue = DateTime.now().add(const Duration(days: 365));

      final sub = Subscription(
        name: _nameController.text,
        amount: amount,
        category: 'Bills 📄',
        startDate: DateTime.now(),
        frequency: _selectedFrequency,
        nextDueDate: nextDue,
        billingDay: billingDay,
        chargeFirstInterval: _chargeFirstInterval,
        defaultRouting: _routing,
      );
      context.read<SubscriptionProvider>().addSubscription(sub);
      
      if (_chargeFirstInterval && _routing != 'none') {
         final settProv = context.read<SettingsProvider>();
         final exp = Expense(
          amount: amount,
          date: DateTime.now(),
          category: 'Bills 📄',
          note: 'Subscription: ${_nameController.text}',
          isRecurring: false,
          lifeCostHours: LifeCostUtils.calculate(amount, settProv.settings.hourlyWage),
          fundingSource: _routing,
        );
        // Correctly handle immediate charge based on routing
        if (_routing == 'allowance') {
          context.read<ExpenseProvider>().addExpense(exp, settProv, skipResourceUpdate: true);
          settProv.deductFromResources(amount);
        } else if (_routing == 'resources') {
          context.read<ExpenseProvider>().addExpense(exp, settProv, skipResourceUpdate: true);
          settProv.deductFromResources(amount);
        }
      }
    }

    final settProv = context.read<SettingsProvider>();
    if (!settProv.settings.isPro && !settProv.settings.adsRemoved) {
      settProv.incrementAdCounter();
      if (settProv.adClickCounter >= 2) {
        AdService.showInterstitialAd(() {
          settProv.resetAdCounter();
          if (mounted) Navigator.pop(context);
        });
        return;
      }
    }

    Navigator.pop(context);
  }
}
