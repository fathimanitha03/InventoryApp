import 'package:flutter/material.dart';

class StockCheckScreen extends StatelessWidget {
  const StockCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock Check')),
      body: const Center(
        child: Text('Stock Check Screen'),
      ),
    );
  }
}