import 'package:flutter/material.dart';

class FormSection extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final List<String>? autofillHints; // Add autofillHints parameter

  const FormSection({
    Key? key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.autofillHints, // Add autofillHints parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              fillColor: Colors.grey.shade200,
              filled: true,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[500]),
            ),
            autofillHints: autofillHints, // Use the autofillHints parameter
          ),
        ],
      ),
    );
  }
}
