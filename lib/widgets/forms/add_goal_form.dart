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
            "Set Financial Goal",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Goal Name (e.g. New Car)",
            ),
          ),
          TextField(
            controller: _targetController,
            decoration: const InputDecoration(labelText: "Target Amount"),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () {
                final goal = Goal(
                  name: _nameController.text,
                  targetAmount: double.tryParse(_targetController.text) ?? 0,
                );
                context.read<GoalsProvider>().addGoal(goal);
                Navigator.pop(context);
              },
              child: const Text(
                "Create Goal",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
