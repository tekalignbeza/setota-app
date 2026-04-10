import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Reset Password (token: $token)'),
      ),
    );
  }
}
