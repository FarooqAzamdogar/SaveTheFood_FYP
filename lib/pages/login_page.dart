import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:savethefood/components/forgot_password_page.dart';
import 'package:savethefood/components/my_button.dart';
import 'package:savethefood/components/my_textfield.dart';
import 'package:savethefood/helper/helper_functions.dart';
import 'package:savethefood/models/story_list.dart';
import 'package:savethefood/pages/admin_page.dart';
import 'package:savethefood/pages/register_page.dart';
import 'package:savethefood/pages/request_status_page.dart';
import 'package:savethefood/pages/volunteer_dashboard.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({Key? key, this.onTap}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      displayMessageToUser('Please enter both email and password', context);
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      displayMessageToUser('Please enter a valid email address', context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      print('UID: $uid'); // Debugging: Print UID

      // Fetch the user's role from Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        Navigator.pop(context);
        displayMessageToUser('User data not found', context);
        print(
            'User document does not exist for UID: $uid'); // Debugging: Document not found
        return;
      }

      final data = userDoc.data() as Map<String, dynamic>;
      final role = data['role'] ?? 'Select an Option';
      print('Document Data: $data'); // Debugging: Print Document Data
      print('Role: $role'); // Debugging: Print Role

      Navigator.pop(context); // Dismiss loading dialog

      Widget nextPage;
      switch (role) {
        case 'Volunteer':
          nextPage = const VolunteerDashboard();
          break;
        case 'Donor':
          nextPage = RequestStatusPage(
            userId: uid,
            type: 'donor',
          );
          break;
        case 'Recipient':
          nextPage = RequestStatusPage(
            userId: uid,
            type: 'recipient',
          );
          break;
        case 'admin':
          final StoriesList storiesList = StoriesList();

          nextPage = AdminPage(
            storiesList: storiesList,
          );
          break;
        default:
          displayMessageToUser('Unknown role: $role', context);
          print('Unknown role: $role'); // Debugging: Unknown role
          return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Dismiss loading dialog
      displayMessageToUser(e.message ?? 'Login failed', context);
    } catch (e) {
      Navigator.pop(context); // Dismiss loading dialog
      displayMessageToUser('An unexpected error occurred: $e', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/img/stf.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 25),
              const Text(
                "Welcome back! You've been missed",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 50),
              MytextField(
                hintText: "Enter your Email",
                obscureText: false,
                controller: emailController,
              ),
              const SizedBox(height: 10),
              MytextField(
                hintText: "Enter your Password",
                obscureText: true,
                controller: passwordController,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              MyButton(
                text: "Login",
                onTap: login,
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterPage(
                            onTap: widget.onTap,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "Register Here",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
