/*import 'package:flutter/material.dart';
import 'package:savethefood/components/signup_button.dart';
import 'package:savethefood/pages/login_page.dart';
import 'package:savethefood/components/form_section.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({Key? key}) : super(key: key);

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final cnicController = TextEditingController();
  final dobController = TextEditingController();
  final birthPlaceController = TextEditingController();
  final nationalityController = TextEditingController();
  final genderController = TextEditingController();
  final religionController = TextEditingController();
  final foodDislikeController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUserIn() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/img/stf.png',
                      color: Colors.black,
                      height: 150,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.only(left: 25.0),
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      color: Color.fromARGB(255, 79, 77, 77),
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.8,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                FormSection(
                  label: 'Full Name',
                  hintText: 'Please enter your full name...',
                  controller: fullNameController,
                ),
                FormSection(
                  label: 'E-mail',
                  hintText: 'Please enter your email...',
                  controller: emailController,
                ),
                FormSection(
                  label: 'Mobile Number',
                  hintText: 'Please enter your mobile number...',
                  controller: mobileNumberController,
                ),
                FormSection(
                  label: 'CNIC',
                  hintText: 'Please enter your CNIC...',
                  controller: cnicController,
                ),
                FormSection(
                  label: 'Date Of Birth',
                  hintText: 'Please enter your date of birth...',
                  controller: dobController,
                ),
                FormSection(
                  label: 'Birth Place',
                  hintText: 'Please enter your place of birth...',
                  controller: birthPlaceController,
                ),
                FormSection(
                  label: 'Nationality',
                  hintText: 'Please enter your nationality...',
                  controller: nationalityController,
                ),
                FormSection(
                  label: 'Gender',
                  hintText: 'Please select your gender...',
                  controller: genderController,
                ),
                FormSection(
                  label: 'Religion',
                  hintText: 'Please enter your religion...',
                  controller: religionController,
                ),
                FormSection(
                  label: 'Food Dislike/Haram',
                  hintText: 'Please select your preferred food type...',
                  controller: foodDislikeController,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          fillColor: Colors.grey.shade200,
                          filled: true,
                          hintText: 'Please enter your password...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Confirm Password',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          fillColor: Colors.grey.shade200,
                          filled: true,
                          hintText: 'Please re-enter your password...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                SignUpButton(
                  onTap: () {
                    //navigate to login page
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ));
                  },
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have a account?',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          //navigate to home page
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ));
                        },
                        child: const Text(
                          'Sign in Now',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/