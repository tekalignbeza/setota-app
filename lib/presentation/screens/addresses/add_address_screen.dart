import 'package:flutter/material.dart';

class AddAddressScreen extends StatelessWidget {
  const AddAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Address')),
      body: const Center(
        child: Text('Add Address'),
      ),
    );
  }
}
