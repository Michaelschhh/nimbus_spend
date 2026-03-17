import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/goal.dart';
import '../../providers/goals_provider.dart';
import '../../theme/colors.dart';

class AddGoalForm extends StatefulWidget {
  const AddGoalForm({super.key});

  @override
  State<AddGoalForm> createState() => _AddGoalFormState();
}

class _AddGoalFormState extends State<AddGoalForm> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();

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
          const Text("Set Financial Goal",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          _field(_nameController, "Goal Name (e.g. New Car)"),
          const SizedBox(height: 12),
          _field(_targetController, "Target Amount", isNum: true),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity, height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                if (_nameController.text.isEmpty) return;
                final goal = Goal(
                  name: _nameController.text,
                  targetAmount: double.tryParse(_targetController.text) ?? 0,
                );
                context.read<GoalsProvider>().addGoal(goal);
                Navigator.pop(context);
              },
              child: const Text("Create Goal",
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
}
