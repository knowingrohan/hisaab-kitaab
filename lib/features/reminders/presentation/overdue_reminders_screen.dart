import 'package:flutter/material.dart';

class OverdueRemindersScreen extends StatelessWidget {
  const OverdueRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overdue Reminders'),
      ),
      body: const Center(
        child: Text('Overdue Reminders\n(Coming in M2)'),
      ),
    );
  }
}
