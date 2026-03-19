import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/debt.dart';
import '../../providers/debt_provider.dart';
import '../../theme/colors.dart';
import '../common/custom_switch.dart';
import '../../providers/settings_provider.dart';
import '../../services/ad_service.dart';

class AddDebtForm extends StatefulWidget {
  final Debt? existingDebt;
  const AddDebtForm({super.key, this.existingDebt});

  @override
  State<AddDebtForm> createState() => _AddDebtFormState();
}

class _AddDebtFormState extends State<AddDebtForm> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  bool _isOwedToMe = false;
  String _routing = 'Monthly Budget';

  @override
  void initState() {
    super.initState();
    if (widget.existingDebt != null) {
      _nameController.text = widget.existingDebt!.personName;
      _amountController.text = widget.existingDebt!.amount.toString();
      _descController.text = widget.existingDebt!.description;
      _isOwedToMe = widget.existingDebt!.isOwedToMe;
      _routing = widget.existingDebt!.defaultRouting ?? 'Monthly Budget';
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
          Text(widget.existingDebt == null ? (_isOwedToMe ? "Money Owed to Me" : "Money I Owe") : "Edit Debt Entry",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Is someone owing you?", style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))),
              CustomSwitch(
                value: _isOwedToMe,
                onChanged: (v) => setState(() => _isOwedToMe = v),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _field(_nameController, "Person Name"),
          const SizedBox(height: 12),
          _field(_amountController, "Amount", isNum: true),
          const SizedBox(height: 12),
          _field(_descController, "Description (Optional)"),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _routing,
            dropdownColor: Theme.of(context).cardColor,
            style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
            items: ['Monthly Budget', 'Available Resources', 'None (Do not log)']
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) => setState(() => _routing = v!),
            decoration: InputDecoration(
              labelText: _isOwedToMe ? "Where funds go" : "Where to pay from",
              labelStyle: const TextStyle(color: AppColors.textDim),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26))),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                if (_nameController.text.isEmpty) return;
                
                if (widget.existingDebt != null) {
                  final debt = Debt(
                    id: widget.existingDebt!.id,
                    personName: _nameController.text,
                    amount: double.tryParse(_amountController.text) ?? 0,
                    description: _descController.text,
                    date: widget.existingDebt!.date,
                    dueDate: widget.existingDebt!.dueDate,
                    isOwedToMe: _isOwedToMe,
                    isSettled: widget.existingDebt!.isSettled,
                    remainingAmount: widget.existingDebt!.remainingAmount,
                    defaultRouting: _routing,
                  );
                  context.read<DebtProvider>().updateDebt(debt);
                } else {
                  final debt = Debt(
                    personName: _nameController.text,
                    amount: double.tryParse(_amountController.text) ?? 0,
                    description: _descController.text,
                    date: DateTime.now(),
                    isOwedToMe: _isOwedToMe,
                    defaultRouting: _routing,
                  );
                  context.read<DebtProvider>().addDebt(debt);
                }

                final sProv = context.read<SettingsProvider>();
                if (!sProv.settings.isPro && !sProv.settings.adsRemoved) {
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
              },
              child: Text(widget.existingDebt == null ? "Add Debt Entry" : "Save Changes",
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
            borderSide: BorderSide(color: Theme.of(context).primaryColor)),
      ),
    );
  }
}
