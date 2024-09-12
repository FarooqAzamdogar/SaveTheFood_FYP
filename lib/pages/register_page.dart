import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:savethefood/components/my_button.dart';
import 'package:savethefood/components/my_textfield.dart';
import 'package:savethefood/helper/helper_functions.dart';
import 'package:savethefood/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // TextEditingController for existing fields
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

  // TextEditingController for new fields
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController religionController = TextEditingController();

  // New field for role selection
  String selectedRole = 'Select an Option';

  // Selected date of birth
  DateTime? selectedDate;

  // Register method
  void registerUser() async {
    // Show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Make sure passwords match
    if (passwordController.text != confirmPwController.text) {
      // Pop loading circle
      Navigator.pop(context);
      // Show error msg to user
      displayMessageToUser("Passwords don't match", context);
      return;
    }

    // Make sure a role is selected
    if (selectedRole == 'Select an Option') {
      Navigator.pop(context);
      displayMessageToUser("Please select a role", context);
      return;
    }

    try {
      // Create the user
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Convert inputs to appropriate types
      int cnic = int.parse(cnicController.text.trim());

      // Save additional user information to Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'cnic': cnic,
        'dob': selectedDate,
        'gender': genderController.text.trim(),
        'religion': religionController.text.trim(),
        'role': selectedRole,
      });

      Navigator.pop(context);
      displayMessageToUser("Registration successful! Please log in.", context);

      // Navigate back to the login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(
            onTap: widget.onTap,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Pop loading circle
      Navigator.pop(context);

      // Display error msg to user
      displayMessageToUser(e.message ?? "An error occurred", context);
    } catch (e) {
      Navigator.pop(context);
      displayMessageToUser("An error occurred: $e", context);
    }
  }

  // Method to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dobController.text =
            "${picked.toLocal()}".split(' ')[0]; // Update text field
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'lib/img/stf.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 5),

                // App name
                const Text(
                  "Save The Food",
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 50),

                // Username textfield
                MytextField(
                  hintText: "Enter your username",
                  obscureText: false,
                  controller: usernameController,
                ),
                const SizedBox(height: 10),

                // Email textfield
                MytextField(
                  hintText: "Enter your Email",
                  obscureText: false,
                  controller: emailController,
                ),
                const SizedBox(height: 10),

                // Password textfield
                MytextField(
                  hintText: "Enter your Password",
                  obscureText: true,
                  controller: passwordController,
                ),
                const SizedBox(height: 10),

                // Confirm password textfield
                MytextField(
                  hintText: "Confirm your Password",
                  obscureText: true,
                  controller: confirmPwController,
                ),
                const SizedBox(height: 10),

                // CNIC textfield
                MytextField(
                  hintText: "Enter your CNIC",
                  obscureText: false,
                  controller: cnicController,
                  keyboardType: TextInputType.number, // Ensure numeric input
                ),
                const SizedBox(height: 10),

                // Date of Birth textfield
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: MytextField(
                      hintText: "Enter your Date of Birth (YYYY-MM-DD)",
                      obscureText: false,
                      controller: dobController,
                      keyboardType: TextInputType.datetime, // Ensure date input
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Gender textfield
                MytextField(
                  hintText: "Enter your Gender",
                  obscureText: false,
                  controller: genderController,
                ),
                const SizedBox(height: 10),

                // Religion textfield
                MytextField(
                  hintText: "Enter your Religion",
                  obscureText: false,
                  controller: religionController,
                ),
                const SizedBox(height: 10),

                // Role dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Who do you want to become",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedRole,
                  items: <String>[
                    'Select an Option',
                    'Volunteer',
                    'Donor',
                    'Recipient',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRole = newValue!;
                    });
                  },
                ),

                const SizedBox(height: 25),

                // Register button
                MyButton(
                  text: "Register",
                  onTap: registerUser,
                ),
                const SizedBox(height: 25),

                // Already have an account? Login here
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Login Here",
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
      ),
    );
  }
}
