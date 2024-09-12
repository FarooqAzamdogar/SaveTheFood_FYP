import 'dart:io'; // Import for handling file operations

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import for picking images from the gallery
import 'package:firebase_storage/firebase_storage.dart'; // Import for Firebase Storage functionalities
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Firestore functionalities
import '../models/story.dart'; // Import the Story model
import '../models/story_list.dart'; // Import the StoriesList model

// AdminPage class to manage and handle admin functionalities like adding, editing, and deleting stories
class AdminPage extends StatefulWidget {
  final StoriesList storiesList; // StoriesList instance to manage stories

  // Constructor with required StoriesList parameter
  const AdminPage({Key? key, required this.storiesList}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

// State class for AdminPage
class _AdminPageState extends State<AdminPage> {
  final _quoteController = TextEditingController(); // Controller for the daily quote text field
  final _storyTitleController = TextEditingController(); // Controller for the story title text field
  final _storyDescriptionController = TextEditingController(); // Controller for the story description text field
  XFile? _selectedImage; // Variable to hold the selected image

  final ImagePicker _picker = ImagePicker(); // Instance of ImagePicker for picking images
  final FirebaseStorage _storage = FirebaseStorage.instance; // Instance of FirebaseStorage for uploading images
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instance of FirebaseFirestore for interacting with Firestore

  List<Story> _stories = []; // List to hold fetched stories
  Story? _editingStory; // Holds the story currently being edited
  bool _isEditingQuote = false; // Flag to track if the quote is being edited
  bool _isEditingStory = false; // Flag to track if a story is being edited

  @override
  void initState() {
    super.initState();
    _fetchStories(); // Fetch stories when the widget is initialized
    _fetchDailyQuote(); // Fetch daily quote when the widget is initialized
  }

  @override
  void dispose() {
    _quoteController.dispose(); // Dispose of quote controller when the widget is disposed
    _storyTitleController.dispose(); // Dispose of story title controller when the widget is disposed
    _storyDescriptionController.dispose(); // Dispose of story description controller when the widget is disposed
    super.dispose();
  }

  // Method to fetch stories from Firestore and update the list
  Future<void> _fetchStories() async {
    try {
      await widget.storiesList.fetchStories(); // Fetch stories using StoriesList instance
      setState(() {
        _stories = widget.storiesList.getStoryList(); // Update the state with the fetched stories
      });
    } catch (e) {
      print('Error fetching stories: $e'); // Print error if fetching fails
    }
  }

  // Method to fetch the daily quote from Firestore
  Future<void> _fetchDailyQuote() async {
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('dailyQuotes') // Access 'dailyQuotes' collection
          .doc('today') // Access the document with ID 'today'
          .get(); // Fetch the document

      if (snapshot.exists) {
        setState(() {
          _quoteController.text = snapshot['quote'] ?? ''; // Set quote text if document exists
        });
      }
    } catch (e) {
      print('Error fetching daily quote: $e'); // Print error if fetching fails
    }
  }

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery); // Pick image from gallery
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile; // Update state with the selected image
        });
      }
    } catch (e) {
      print('Error picking image: $e'); // Print error if picking image fails
    }
  }

  // Method to upload the selected image to Firebase Storage and add or update the story in Firestore
  Future<void> _uploadImageAndAddStory() async {
    print("Starting upload and add story process");
    
    if (_selectedImage == null) {
      print('No image selected'); // Check if no image is selected
      return; // Exit if no image is selected
    }
    
    print('Selected image path: ${_selectedImage!.path}');

    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString(); // Generate a unique file name
      final reference = _storage.ref().child('stories/$fileName'); // Create a reference to the Firebase Storage location
      final uploadTask = reference.putFile(File(_selectedImage!.path)); // Upload the file to Firebase Storage

      final snapshot = await uploadTask.whenComplete(() {}); // Wait for the upload to complete
      final downloadUrl = await snapshot.ref.getDownloadURL(); // Get the download URL of the uploaded image

      final newStory = Story(
        id: '', // No ID when adding a new story
        name: _storyTitleController.text,
        imagePath: downloadUrl,
        description: _storyDescriptionController.text,
        timestamp: Timestamp.now(), // Current timestamp
      );

      if (_isEditingStory && _editingStory != null) {
        print("Updating story");
        await _firestore
            .collection('stories')
            .doc(_editingStory!.id) // Use the document ID from the editing story
            .update(newStory.toMap()); // Update the existing story in Firestore
      } else {
        print("Adding new story");
        final docRef = await _firestore.collection('stories').add(newStory.toMap()); // Add a new story to Firestore
        // Update the newStory object with the generated document ID
        final updatedStory = newStory.copyWith(id: docRef.id);
        await widget.storiesList.addStory(updatedStory); // Add the new story to the list
      }

      print("Story updated/added successfully");

      setState(() {
        _storyTitleController.clear(); // Clear the story title controller
        _storyDescriptionController.clear(); // Clear the story description controller
        _selectedImage = null; // Reset selected image
        _fetchStories(); // Refresh the list of stories
        _isEditingStory = false; // Reset editing story flag
        _editingStory = null; // Clear the editing story
      });
    } catch (e) {
      print('Error uploading image and adding/updating story: $e'); // Print error if upload or update fails
    }
  }

  // Method to save the daily quote to Firestore
  Future<void> _saveDailyQuote() async {
    try {
      final quote = _quoteController.text;
      await _firestore.collection('dailyQuotes').doc('today').set({
        'quote': quote,
        'timestamp': Timestamp.now(), // Add timestamp here
      });
      setState(() {
        _isEditingQuote = false; // Exit editing quote mode
      });
    } catch (e) {
      print('Error saving daily quote: $e'); // Print error if saving fails
    }
  }

  // Method to set up the editing mode for a story
  void _editStory(Story story) {
    setState(() {
      _storyTitleController.text = story.name; // Set the story title in the controller
      _storyDescriptionController.text = story.description; // Set the story description in the controller
      _editingStory = story; // Set the story being edited
      _isEditingStory = true; // Enter editing mode
    });
  }

  // Method to delete a story
  void _deleteStory(Story story) async {
    try {
      await widget.storiesList.removeStory(story); // Remove the story from the list
      setState(() {
        _fetchStories(); // Refresh the list of stories
      });
    } catch (e) {
      print('Error deleting story: $e'); // Print error if deletion fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'), // Title of the admin panel screen
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the content
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isEditingQuote)
                TextField(
                  controller: _quoteController, // Controller for the daily quote text field
                  decoration: const InputDecoration(
                    labelText: 'Daily Quote', // Label for the text field
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    _quoteController.text, // Display the daily quote
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if (!_isEditingQuote)
                ElevatedButton(
                  onPressed: _saveDailyQuote, // Save the daily quote
                  child: const Text('Save Daily Quote'),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditingQuote = false; // Exit editing quote mode
                    });
                  },
                  child: const Text('Edit Daily Quote'),
                ),
              const Divider(height: 32),
              Text(
                _isEditingStory ? 'Edit Story' : 'Add New Story',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _storyTitleController, // Controller for the story title text field
                decoration: const InputDecoration(
                  labelText: 'Story Title', // Label for the text field
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _pickImage, // Pick an image from the gallery
                child: const Text('Pick Image'),
              ),
              if (_selectedImage != null) 
                Image.file(File(_selectedImage!.path), height: 100, width: 100), // Display the selected image
              const SizedBox(height: 8),
              TextField(
                controller: _storyDescriptionController, // Controller for the story description text field
                decoration: const InputDecoration(
                  labelText: 'Description', // Label for the text field
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _uploadImageAndAddStory, // Add or update the story
                child: Text(_isEditingStory ? 'Update Story' : 'Add Story'),
              ),
              const Divider(height: 32),
              Text(
                'Manage Stories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _stories.isEmpty
                  ? Center(child: Text('No stories available')) // Display a message if no stories are available
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _stories.length,
                      itemBuilder: (context, index) {
                        final story = _stories[index];
                        return ListTile(
                          title: Text(story.name), // Display the story title
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editStory(story), // Edit the selected story
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteStory(story), // Delete the selected story
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
