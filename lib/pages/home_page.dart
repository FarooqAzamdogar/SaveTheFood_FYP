import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/story.dart';

// HomePage widget to display daily quotes and a list of stories
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String dailyQuote = ''; // Variable to hold the daily quote
  List<Story> stories = []; // List to hold fetched stories

  @override
  void initState() {
    super.initState();
    fetchDailyQuote(); // Fetch the daily quote when the widget initializes
    fetchStories(); // Fetch the stories when the widget initializes
  }

  // Method to fetch the daily quote from Firestore
  Future<void> fetchDailyQuote() async {
    try {
      // Fetch the document with ID 'today' from the 'dailyQuotes' collection
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('dailyQuotes')
          .doc('today')
          .get();

      if (snapshot.exists) {
        // If the document exists, set the dailyQuote variable with the quote from the document
        setState(() {
          dailyQuote = snapshot['quote'] ?? 'No quote available for today';
        });
      } else {
        // If the document does not exist, set a default message
        setState(() {
          dailyQuote = 'No quote available for today';
        });
      }
    } catch (e) {
      // Handle any errors that occur during fetching
      setState(() {
        dailyQuote = 'Error fetching quote: $e';
      });
    }
  }

  // Method to fetch the list of stories from Firestore
  Future<void> fetchStories() async {
    try {
      // Fetch all documents from the 'stories' collection, ordered by timestamp in descending order
      final snapshot = await FirebaseFirestore.instance
          .collection('stories')
          .orderBy('timestamp', descending: true)
          .get();

      // Map the fetched documents to Story objects and update the stories list
      setState(() {
        stories = snapshot.docs.map((doc) {
          return Story.fromFirestore(
              doc); // Convert Firestore document to Story object
        }).toList();
      });
    } catch (e) {
      // Handle any errors that occur during fetching
      print('Error fetching stories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text('SaveTheFood'), // Title of the app bar
        backgroundColor:
            Colors.transparent, // Make the app bar background transparent
        elevation: 0, // Remove shadow from the app bar
        // Uncomment the following block to add a menu button
        // leading: IconButton(
        //   icon: Icon(Icons.menu),
        //   onPressed: () => Scaffold.of(context).openDrawer(),
        // ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding around the body
        child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .start, // Align items to the start of the column
          children: [
            // Daily Quote Section
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 16.0), // Add bottom padding
              child: Text(
                'Daily Quote', // Title of the daily quote section
                style: TextStyle(
                  fontWeight: FontWeight.bold, // Make the text bold
                  fontSize: 20, // Set font size
                  decoration:
                      TextDecoration.underline, // Add underline decoration
                  decorationThickness: 1.5, // Set thickness of the underline
                  decorationColor:
                      Colors.grey[400], // Set color of the underline
                  color: Colors.grey[600], // Set color of the text
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.all(16), // Add padding inside the container
              margin: const EdgeInsets.symmetric(
                  vertical: 8), // Add vertical margin around the container
              decoration: BoxDecoration(
                color:
                    Colors.grey[200], // Set background color of the container
                borderRadius: BorderRadius.circular(8), // Add rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(
                        0.5), // Set color and opacity of the shadow
                    spreadRadius: 2, // Set the spread radius of the shadow
                    blurRadius: 4, // Set the blur radius of the shadow
                    offset: Offset(0, 3), // Set the offset of the shadow
                  ),
                ],
              ),
              child: Text(
                dailyQuote, // Display the daily quote
                style: TextStyle(
                  fontSize: 16, // Set font size
                  color: Colors.grey[700], // Set color of the text
                ),
                textAlign: TextAlign.center, // Center-align the text
              ),
            ),
            SizedBox(height: 20), // Add space between sections
            // Stories Section
            Text(
              'Latest Stories', // Title of the stories section
              style: TextStyle(
                fontWeight: FontWeight.bold, // Make the text bold
                fontSize: 24, // Set font size
              ),
            ),
            SizedBox(height: 10), // Add space between sections
            Expanded(
              child: ListView.builder(
                itemCount: stories.length, // Number of items in the list
                itemBuilder: (context, index) {
                  final story =
                      stories[index]; // Get the story at the current index
                  return Padding(
                    padding: const EdgeInsets.only(
                        bottom: 12.0), // Add bottom padding
                    child: Card(
                      elevation: 4, // Set elevation of the card
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            12), // Add rounded corners to the card
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(
                            12), // Add padding inside the ListTile
                        leading: story.imagePath.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    8), // Add rounded corners to the image
                                child: Image.network(
                                  story.imagePath, // Display the story image
                                  width: 60, // Set width of the image
                                  height: 60, // Set height of the image
                                  fit: BoxFit
                                      .cover, // Set how the image should fit in the box
                                ),
                              )
                            : null, // If no image, set leading to null
                        title: Text(
                          story.name, // Display the story name
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold, // Make the story name bold
                          ),
                        ),
                        subtitle: Text(
                            story.description), // Display the story description
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Uncomment the following block to add a bottom navigation bar
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.search),
      //       label: 'Search',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.notifications),
      //       label: 'Notifications',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.account_circle),
      //       label: 'Profile',
      //     ),
      //   ],
      //   onTap: (index) {
      //     // Handle bottom navigation tab changes
      //   },
      // ),
    );
  }
}
