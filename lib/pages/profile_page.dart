import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'info_cards.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<DocumentSnapshot> userData;

  @override
  void initState() {
    super.initState();
    userData = fetchUserData();
  }

  Future<DocumentSnapshot> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      return await FirebaseFirestore.instance.collection('users').doc(userId).get();
    } else {
      throw Exception("No user logged in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<DocumentSnapshot>(
        future: userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error fetching data"));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("User not found"));
          } else {
            var data = snapshot.data!.data() as Map<String, dynamic>;

            // Explicitly cast the data to expected types
            String username = data['username']?.toString() ?? "N/A";
            String email = data['email']?.toString() ?? "N/A";
            String cnic = data['cnic']?.toString() ?? "N/A";
          String dob = DateFormat('yyyy-MM-dd').format(data['dob'].toDate());
            String gender = data['gender']?.toString() ?? "N/A";
            String religion = data['religion']?.toString() ?? "N/A";
            String role = data['role']?.toString() ?? "N/A";

            return SingleChildScrollView(
              child: SafeArea(
                minimum: const EdgeInsets.only(top: 100),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      // const CircleAvatar(
                      //   radius: 50,
                      //   backgroundImage: AssetImage('lib/img/farooq.jpg'),
                      // ),
                      Column(
                        children: [
                          Text(
                            username,
                            style: TextStyle(
                              fontSize: 35.0,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                              fontFamily: "Pacifico",
                            ),
                          ),
                          Text(
                            role,
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.grey[700],
                              letterSpacing: 2.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                        width: 200,
                        child: Divider(
                          color: Colors.white,
                        ),
                      ),
                      InfoCard(
                        text: cnic,
                        icon: Icons.credit_card,
                        onPressed: () async {},
                        editable: false,
                      ),
                      InfoCard(
                        text: dob,
                        icon: Icons.calendar_today,
                        onPressed: () async {},
                        editable: false,
                      ),
                      InfoCard(
                        text: email,
                        icon: Icons.email,
                        onPressed: () async {},
                        editable: false,
                      ),
                      InfoCard(
                        text: gender,
                        icon: Icons.person,
                        onPressed: () async {},
                        editable: false,
                      ),
                      InfoCard(
                        text: religion,
                        icon: Icons.accessibility_new,
                        onPressed: () async {},
                        editable: false,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
