import 'package:flutter/material.dart';
import 'package:savethefood/components/custom_button.dart';

class SignInButton extends StatelessWidget {
  final Function()? onTap;

  const SignInButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      buttonText: 'Sign in',
      onTap: onTap,
    );
  }
}
