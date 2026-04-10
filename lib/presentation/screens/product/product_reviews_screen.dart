import 'package:flutter/material.dart';

class ProductReviewsScreen extends StatelessWidget {
  final String productId;

  const ProductReviewsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: Center(
        child: Text('Reviews for product: $productId'),
      ),
    );
  }
}
