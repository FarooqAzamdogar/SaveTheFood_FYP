import 'package:flutter/material.dart';

class MytextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final TextInputType keyboardType; // Add this line

  MytextField({
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.keyboardType = TextInputType.text, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType, // Add this line
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(),
      ),
    );
  }
}
