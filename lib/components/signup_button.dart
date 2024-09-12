import 'package:flutter/material.dart';
import 'package:savethefood/components/custom_button.dart';

class SignUpButton extends StatelessWidget {
  final Function()? onTap;

  const SignUpButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      buttonText: 'Sign Up',
      onTap: onTap,
    );
  }
}
