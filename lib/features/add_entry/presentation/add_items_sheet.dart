import 'package:flutter/material.dart';

class AddItemsSheet extends StatelessWidget {
  const AddItemsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Entry'),
      ),
      body: const Center(
        child: Text('Add Items Entry\n(Coming in M1)'),
      ),
    );
  }
}
