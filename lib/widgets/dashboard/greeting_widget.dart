import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class GreetingWidget extends StatelessWidget {
  const GreetingWidget({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    final name = context.watch<SettingsProvider>().settings.name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${_getGreeting()},",
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.grey),
        ),
        Text(
          "$name ☀️",
          style: Theme.of(
            context,
          ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
