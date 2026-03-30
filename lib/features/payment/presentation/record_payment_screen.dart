import 'package:flutter/material.dart';

class RecordPaymentScreen extends StatelessWidget {
  final int customerId;

  const RecordPaymentScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Payment'),
      ),
      body: Center(
        child: Text('Record Payment for Customer #$customerId\n(Coming in M1)'),
      ),
    );
  }
}
