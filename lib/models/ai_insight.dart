import 'package:flutter/material.dart';

class AIInsight {
  final String title;
  final String body;
  final IconData icon;
  final String? actionLabel;
  final String? route;

  AIInsight({
    required this.title,
    required this.body,
    required this.icon,
    this.actionLabel,
    this.route,
  });
}
