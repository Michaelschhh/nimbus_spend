import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/bill.dart';
import '../../providers/bills_provider.dart';
import '../../theme/colors.dart';

class AddBillForm extends StatefulWidget {
  const AddBillForm({super.key});

  @override
  State<AddBillForm> createState() => _AddBillFormState();
}

class _AddBillFormState extends State<AddBillForm> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _frequency = 'Monthly';

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
          const Text("Add New Bill",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          _field(_nameController, "Bill Name (e.g. Rent)"),
          const SizedBox(height: 12),
          _field(_amountController, "Amount", isNum: true),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _frequency,
            dropdownColor: AppColors.cardBg,
            style: const TextStyle(color: Colors.white),
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
                  borderSide: const BorderSide(color: Colors.white24)),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Due Date", style: TextStyle(color: AppColors.textDim)),
            subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedDate),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.calendar_today, color: AppColors.primary),
            onTap: () async {
              final date = await showDatePicker(
                context: context, initialDate: DateTime.now(),
                firstDate: DateTime.now(), lastDate: DateTime(2100),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
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
              child: const Text("Save Bill",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: AppColors.textDim),
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
    if (_nameController.text.isEmpty) return;
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) return;

    final bill = Bill(
      name: _nameController.text,
      amount: amount,
      dueDate: _selectedDate,
      frequency: _frequency,
      category: 'Bills 📄',
    );

    context.read<BillsProvider>().addBill(bill);
    Navigator.pop(context);
  }
}
