import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:savethefood/auth/login_or_register.dart';
import 'package:savethefood/pages/donor_dashboard.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //user is logged in
          if (snapshot.hasData) {
            return const DonorDashboard();
          }
          //user is not logged in
          else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
