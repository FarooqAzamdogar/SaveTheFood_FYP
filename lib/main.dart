import 'package:firebase_messaging/firebase_messaging.dart'; // Import for Firebase Cloud Messaging
import 'package:flutter/material.dart'; // Import for Flutter's material design widgets
import 'package:firebase_core/firebase_core.dart'; // Import for initializing Firebase
import 'package:savethefood/pages/donor_dashboard.dart'; // Import custom pages
import 'package:savethefood/pages/home_page.dart';
import 'package:savethefood/pages/login_page.dart';
import 'package:savethefood/pages/recipient_dashboard.dart';
import 'package:savethefood/pages/request_status_page.dart';
import 'package:savethefood/pages/volunteer_dashboard.dart';
import 'package:savethefood/theme/dark_mode.dart'; // Import for dark mode theme
import 'package:savethefood/theme/light_mode.dart'; // Import for light mode theme
import 'my_bottom_nav_bar.dart'; // Import custom bottom navigation bar component

// Function to handle background messages from Firebase Cloud Messaging
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized before handling the background message
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter framework is initialized before running the app
  await Firebase.initializeApp(); // Initialize Firebase services
  FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler); // Set up background message handling

  runApp(const MyApp()); // Run the main app widget
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState(); // Create the state for MyApp
}

class _MyAppState extends State<MyApp> {
  // Index to track the currently selected page in the bottom navigation bar
  int _selectedIndex = 0;

  // List of pages to be displayed in the bottom navigation bar
  final List<Widget> _pages = [
    HomePage(), // Home page
    const LoginPage(), // Login page
    const VolunteerDashboard(), // Volunteer Dashboard page
    const RequestStatusPage(
        userId: '', type: ''), // Request Status page with placeholder values
    const DonorDashboard(), // Donor Dashboard page
    const RecipientDashboard(), // Recipient Dashboard page
  ];

  // Function to handle tab changes in the bottom navigation bar
  void _onTabChange(int index) {
    setState(() {
      _selectedIndex =
          index; // Update the selected index based on the tapped tab
    });
  }

  // Function to handle the back button press
  Future<bool> _onWillPop() async {
    // ignore: unused_local_variable
    final currentPage = _pages[_selectedIndex];

    // Check if the current page has a navigation stack to pop
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop(); // Pop the top route off the navigator stack
      return false; // Prevent app from closing if there is a navigation stack
    } else {
      return true; // Allow app to close if there's no navigation stack to pop
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable the debug banner
      // Routes configuration
      routes: {
        '/home': (context) => HomePage(), // Route for Home Page
        '/login': (context) => const LoginPage(), // Route for Login Page
        '/volunteer_dashboard': (context) =>
            const VolunteerDashboard(), // Route for Volunteer Dashboard
        '/request_status': (context) => const RequestStatusPage(
            userId: '',
            type: ''), // Route for Request Status with placeholder values
        '/donor_dashboard': (context) =>
            const DonorDashboard(), // Route for Donor Dashboard
        '/recipient_dashboard': (context) =>
            const RecipientDashboard(), // Route for Recipient Dashboard
      },
      onGenerateRoute: (settings) {
        // Handle dynamic routes with arguments
        if (settings.name == '/request_status') {
          final args = settings.arguments as Map<String, String>;
          final userId = args['userId'] ?? '';
          final type = args['type'] ?? '';
          return MaterialPageRoute(
            builder: (context) => RequestStatusPage(userId: userId, type: type),
          );
        }
        return null; // Return null if route name does not match
      },
      theme: lightMode, // Apply the light mode theme
      darkTheme: darkMode, // Apply the dark mode theme
      themeMode: ThemeMode
          .system, // Use system theme mode (dark or light based on system settings)
      home: WillPopScope(
        onWillPop: _onWillPop, // Handle back button press using WillPopScope
        child: Scaffold(
          body: IndexedStack(
            index:
                _selectedIndex, // Display the page based on the selected index
            children: _pages, // List of pages for the IndexedStack
          ),
          bottomNavigationBar: MyBottomNavBar(
            onTabChange:
                _onTabChange, // Pass the tab change handler to MyBottomNavBar
          ),
        ),
      ),
    );
  }
}
