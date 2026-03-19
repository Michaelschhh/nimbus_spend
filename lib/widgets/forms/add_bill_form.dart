import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/bill.dart';
import '../../providers/bills_provider.dart';
import '../../theme/colors.dart';
import '../common/custom_switch.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/settings_provider.dart';
import '../../services/ad_service.dart';

class AddBillForm extends StatefulWidget {
  final Bill? existingBill;
  const AddBillForm({super.key, this.existingBill});

  @override
  State<AddBillForm> createState() => _AddBillFormState();
}

class _AddBillFormState extends State<AddBillForm> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _frequency = 'Monthly';
  bool _autoPay = false;
  String _routing = 'allowance';

  @override
  void initState() {
    super.initState();
    if (widget.existingBill != null) {
      _nameController.text = widget.existingBill!.name;
      _amountController.text = widget.existingBill!.amount.toString();
      _selectedDate = widget.existingBill!.dueDate;
      // Handle the case where an older bill might have a frequency not in our list
      if (['Weekly', 'Monthly', 'Yearly', 'Once'].contains(widget.existingBill!.frequency)) {
        _frequency = widget.existingBill!.frequency;
      }
      _autoPay = widget.existingBill!.autoPay;
      _routing = widget.existingBill!.defaultRouting;
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
          Text(widget.existingBill == null ? "Add New Bill" : "Edit Bill",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))),
          const SizedBox(height: 20),
          _field(_nameController, "Bill Name (e.g. Rent)"),
          const SizedBox(height: 12),
          _field(_amountController, "Amount", isNum: true),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _frequency,
            dropdownColor: Theme.of(context).cardColor,
            style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
            items: ['Weekly', 'Monthly', 'Yearly', 'Once']
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (v) => setState(() => _frequency = v!),
            decoration: InputDecoration(
              labelText: "Frequency",
              labelStyle: const TextStyle(color: AppColors.textDim),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26))),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Due Date", style: TextStyle(color: AppColors.textDim)),
            subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedDate),
                style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.calendar_today, color: AppColors.primary),
            onTap: () async {
              final date = await showDatePicker(
                context: context, initialDate: DateTime.now(),
                firstDate: DateTime.now(), lastDate: DateTime(2100),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Auto Pay on Due Date?", style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontSize: 14)),
              CustomSwitch(
                value: _autoPay,
                onChanged: (v) => setState(() => _autoPay = v),
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
              prefixIcon: const Icon(LucideIcons.wallet, color: AppColors.primary, size: 18),
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
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: _save,
              child: Text(widget.existingBill == null ? "Save Bill" : "Save Changes",
                  style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, {bool isNum = false}) {
    return TextField(
      controller: c,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: AppColors.textDim),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors.primary)),
      ),
    );
  }

  void _save() {
    if (_nameController.text.isEmpty) return;
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) return;

    if (widget.existingBill != null) {
      final bill = Bill(
        id: widget.existingBill!.id,
        name: _nameController.text,
        amount: amount,
        dueDate: _selectedDate,
        frequency: _frequency,
        category: widget.existingBill!.category,
        isPaid: widget.existingBill!.isPaid,
        paidDate: widget.existingBill!.paidDate,
        autoPay: _autoPay,
        defaultRouting: _routing,
      );
      context.read<BillsProvider>().updateBill(bill);
    } else {
      final bill = Bill(
        name: _nameController.text,
        amount: amount,
        dueDate: _selectedDate,
        frequency: _frequency,
        category: 'Bills 📄',
        autoPay: _autoPay,
        defaultRouting: _routing,
      );
      context.read<BillsProvider>().addBill(bill);
    }
    
    final sProv = context.read<SettingsProvider>();

    if (!sProv.settings.isPro) {
      sProv.incrementAdCounter();
      if (sProv.adClickCounter >= 2) {
        AdService.showInterstitialAd(() {
          sProv.resetAdCounter();
          if (mounted) Navigator.pop(context);
        });
        return;
      }
    }

    Navigator.pop(context);
  }
}
