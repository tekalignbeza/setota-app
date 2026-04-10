import 'package:flutter/material.dart';

class VendorDetailScreen extends StatelessWidget {
  final String vendorId;

  const VendorDetailScreen({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor')),
      body: Center(
        child: Text('Vendor: $vendorId'),
      ),
    );
  }
}
