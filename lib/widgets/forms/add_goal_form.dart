import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/goal.dart';
import '../../providers/goals_provider.dart';
import '../../theme/colors.dart';
import '../../providers/settings_provider.dart';
import '../../services/ad_service.dart';
import '../common/apple_button.dart';

class AddGoalForm extends StatefulWidget {
  final Goal? existingGoal;
  const AddGoalForm({super.key, this.existingGoal});

  @override
  State<AddGoalForm> createState() => _AddGoalFormState();
}

class _AddGoalFormState extends State<AddGoalForm> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingGoal != null) {
      _nameController.text = widget.existingGoal!.name;
      _targetController.text = widget.existingGoal!.targetAmount.toString();
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
          Text(widget.existingGoal == null ? "Set Financial Goal" : "Edit Financial Goal",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))),
          const SizedBox(height: 20),
          _field(_nameController, "Goal Name (e.g. New Car)"),
          const SizedBox(height: 12),
          _field(_targetController, "Target Amount", isNum: true),
          const SizedBox(height: 25),
          AppleButton(
            label: widget.existingGoal == null ? "Create Goal" : "Save Changes",
            onTap: () {
              if (_nameController.text.isEmpty) return;
                
                if (widget.existingGoal != null) {
                  final goal = Goal(
                    id: widget.existingGoal!.id,
                    name: _nameController.text,
                    targetAmount: double.tryParse(_targetController.text) ?? 0,
                    currentAmount: widget.existingGoal!.currentAmount,
                    deadline: widget.existingGoal!.deadline,
                    isCompleted: widget.existingGoal!.isCompleted,
                    completedDate: widget.existingGoal!.completedDate,
                  );
                  context.read<GoalsProvider>().updateGoal(goal);
                } else {
                  final goal = Goal(
                    name: _nameController.text,
                    targetAmount: double.tryParse(_targetController.text) ?? 0,
                  );
                  context.read<GoalsProvider>().addGoal(goal);
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
