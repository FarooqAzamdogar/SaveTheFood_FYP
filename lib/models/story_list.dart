import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/story.dart';

// A class to manage a list of stories with operations like fetching, adding, removing, and updating stories.
class StoriesList {
  // Instance of Firestore database
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Local list to hold stories fetched from Firestore
  final List<Story> _stories = [];

  // Getter to expose an immutable list of stories
  List<Story> getStoryList() => List.unmodifiable(_stories);

  // Method to fetch stories from Firestore and update the local list
  Future<void> fetchStories() async {
    try {
      // Fetch documents from the 'stories' collection, ordered by 'timestamp' in descending order
      final snapshot = await _firestore.collection('stories').orderBy('timestamp', descending: true).get();
      
      // Clear the local list before adding new stories
      _stories.clear();
      
      // Iterate over each document and convert it to a Story object
      for (var doc in snapshot.docs) {
        _stories.add(Story.fromFirestore(doc));
      }
    } catch (e) {
      // Print error message if fetching stories fails
      print('Error fetching stories: $e');
    }
  }

  // Method to add a new story to Firestore and update the local list
  Future<void> addStory(Story story) async {
    try {
      // Add the story to the 'stories' collection in Firestore
      await _firestore.collection('stories').add(story.toMap());
      
      // Add the story to the local list
      _stories.add(story);
    } catch (e) {
      // Print error message if adding the story fails
      print('Error adding story: $e');
    }
  }

  // Method to remove a story from Firestore and update the local list
  Future<void> removeStory(Story story) async {
    try {
      // Query for the story to delete by matching its 'name' field
      final snapshot = await _firestore
          .collection('stories')
          .where('name', isEqualTo: story.name)
          .limit(1) // Limit to one document to avoid deleting multiple records
          .get();
      
      // Iterate over each document in the snapshot and delete it
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      
      // Remove the story from the local list
      _stories.remove(story);
    } catch (e) {
      // Print error message if removing the story fails
      print('Error removing story: $e');
    }
  }

  // Method to update an existing story in Firestore and the local list
  Future<void> updateStory(int index, Story newStory) async {
    try {
      // Query for the story to update by matching its 'name' field
      final snapshot = await _firestore
          .collection('stories')
          .where('name', isEqualTo: _stories[index].name)
          .limit(1) // Limit to one document to avoid updating multiple records
          .get();
      
      // Iterate over each document in the snapshot and update it
      for (var doc in snapshot.docs) {
        await doc.reference.update(newStory.toMap());
      }
      
      // Update the local list with the new story
      _stories[index] = newStory;
    } catch (e) {
      // Print error message if updating the story fails
      print('Error updating story: $e');
    }
  }
}
