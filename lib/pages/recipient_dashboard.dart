import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:savethefood/components/form_section.dart';
import 'package:savethefood/components/custom_button.dart';
import 'package:savethefood/pages/profile_page.dart';
import 'package:savethefood/pages/request_status_page.dart';
import 'package:savethefood/pages/api_service.dart';
import 'package:savethefood/pages/request_model.dart';

class RecipientDashboard extends StatefulWidget {
  const RecipientDashboard({Key? key}) : super(key: key);

  @override
  _RecipientDashboardState createState() => _RecipientDashboardState();
}

class _RecipientDashboardState extends State<RecipientDashboard> {
  final TextEditingController coordinatesController = TextEditingController();
  final TextEditingController foodServingsController = TextEditingController();
  final TextEditingController foodTypeController = TextEditingController();
  final TextEditingController recipientAddressController =
      TextEditingController();

  String errorMessage = ''; // Add this line to manage error messages

  Future<void> fetchCoordinates() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      if (await Permission.location.request().isGranted) {
        // Permission granted
        try {
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          coordinatesController.text =
              '${position.latitude}, ${position.longitude}';
        } catch (e) {
          coordinatesController.text = 'Error fetching location';
          print('Error fetching location: $e');
        }
      } else {
        // Permission denied
        coordinatesController.text = 'Location permission denied';
      }
    } else if (status.isGranted) {
      // Permission already granted
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        coordinatesController.text =
            '${position.latitude}, ${position.longitude}';
      } catch (e) {
        coordinatesController.text = 'Error fetching location';
        print('Error fetching location: $e');
      }
    }
  }

  void submitRequest() async {
    try {
      print("submit button pressed");
      User? user = FirebaseAuth.instance.currentUser; // Get the current user
      if (user == null) {
        print('No user is currently signed in.');
        return;
      }
      String userId = user.uid; // Get the user ID

      DatabaseReference databaseReference =
          FirebaseDatabase.instance.ref().child('requests').push();
      String requestId = databaseReference.key ?? ''; // Handle nullability
      var request = Request(
        id: requestId,
        type: 'recipient',
        senderId: userId, // Replace with actual user ID
        status: 'pending',
        details: {
          'food_servings': foodServingsController.text,
          'food_type': foodTypeController.text,
          'recipient_address': recipientAddressController.text,
          'coordinates': coordinatesController.text,
        },
      );

      print('Submitting request: ${request.toMap()}');
      await ApiService.submitRequest(request.toMap());
      print('Request submitted successfully');

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RequestStatusPage(
          userId: userId,
          type: 'recipient',
        ),
      ));
    } catch (e) {
      setState(() {
        errorMessage = 'You already have a pending request.';
      });
      print('Error submitting request: $e');
      // Optionally show a snackbar or dialog to notify the user of the error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Recipient Dashboard'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                    child: Text("Go to Profile"),
                  ),
                ),
                const SizedBox(height: 30),
                FormSection(
                  label: 'Food Servings',
                  hintText: 'Please enter the number of servings...',
                  controller: foodServingsController,
                ),
                FormSection(
                  label: 'Food Type',
                  hintText: 'Please specify food type (Halal, Haram, Any)...',
                  controller: foodTypeController,
                ),
                FormSection(
                  label: 'Recipient Address',
                  hintText: 'Please enter your address...',
                  controller: recipientAddressController,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Coordinates',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: coordinatesController,
                        readOnly: true,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          fillColor: Colors.grey.shade200,
                          filled: true,
                          hintText: 'Coordinates will be fetched here...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: fetchCoordinates,
                        child: const Text('Fetch Coordinates'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (errorMessage.isNotEmpty) // Display error message if present
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text(
                      errorMessage,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
                CustomButton(
                  buttonText: 'Submit',
                  onTap: submitRequest,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
