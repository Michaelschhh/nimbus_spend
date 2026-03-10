import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // FIXED: Missing import
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

  @override
  Widget build(BuildContext context) {
    // FIXED: Define 'now' variable
    final DateTime now = DateTime.now();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Add New Bill",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Bill Name (e.g. Rent)",
            ),
          ),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: "Amount"),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          ListTile(
            title: const Text("Due Date"),
            subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: now,
                firstDate: now,
                lastDate: DateTime(2100),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: _save,
              child: const Text(
                "Save Bill",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (_nameController.text.isEmpty) return;
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    final bill = Bill(
      name: _nameController.text,
      amount: amount,
      dueDate: _selectedDate,
      frequency: 'Monthly',
      category: 'Bills 📄',
    );

    context.read<BillsProvider>().addBill(bill);
    Navigator.pop(context);
  }
}
