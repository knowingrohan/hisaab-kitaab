import 'package:flutter/material.dart';

class CustomerDetailScreen extends StatelessWidget {
  final int customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Detail'),
      ),
      body: Center(
        child: Text('Customer #$customerId Detail\n(Coming in M1)'),
      ),
    );
  }
}
