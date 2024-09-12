import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:savethefood/components/my_button.dart';
import 'package:savethefood/components/my_textfield.dart';
import 'package:savethefood/helper/helper_functions.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  void resetPassword() async {
    if (emailController.text.isEmpty) {
      displayMessageToUser("Please enter your email", context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      Navigator.pop(context);
      displayMessageToUser('Password reset email sent!', context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      displayMessageToUser(e.message ?? "An error occurred", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text("Forgot Password"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email textfield
              MytextField(
                hintText: "Enter your Email",
                obscureText: false,
                controller: emailController,
              ),
              const SizedBox(height: 25),

              // Reset password button
              MyButton(
                text: "Reset Password",
                onTap: resetPassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
