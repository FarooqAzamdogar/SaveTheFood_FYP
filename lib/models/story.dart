import 'package:cloud_firestore/cloud_firestore.dart';

// The Story class represents a story object with properties and methods to interact with Firestore.
class Story {
  // Unique identifier for the story (usually Firestore document ID)
  final String id;
  
  // Name of the story
  final String name;
  
  // Path to the image associated with the story
  final String imagePath;
  
  // Description of the story
  final String description;
  
  // Timestamp indicating when the story was created or last updated
  final Timestamp timestamp;

  // Constructor for creating a Story instance with all required fields
  Story({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.description,
    required this.timestamp,
  });

  // Factory constructor to create a Story instance from a Firestore document snapshot
  factory Story.fromFirestore(DocumentSnapshot doc) {
    // Convert the document data into a Map
    final data = doc.data() as Map<String, dynamic>;
    
    // Create and return a Story instance with the data from the Firestore document
    return Story(
      id: doc.id, // Document ID as the story's unique identifier
      name: data['name'], // Retrieve 'name' from the document data
      imagePath: data['imagePath'], // Retrieve 'imagePath' from the document data
      description: data['description'], // Retrieve 'description' from the document data
      timestamp: data['timestamp'], // Retrieve 'timestamp' from the document data
    );
  }

  // Method to convert a Story instance to a Map, suitable for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'name': name, // Map 'name' to the story's name
      'imagePath': imagePath, // Map 'imagePath' to the story's image path
      'description': description, // Map 'description' to the story's description
      'timestamp': timestamp, // Map 'timestamp' to the story's timestamp
    };
  }

  // Method to create a copy of the Story instance with optional modifications
  Story copyWith({
    String? id,
    String? name,
    String? imagePath,
    String? description,
    Timestamp? timestamp,
  }) {
    return Story(
      id: id ?? this.id, // Use provided 'id' or keep the current 'id'
      name: name ?? this.name, // Use provided 'name' or keep the current 'name'
      imagePath: imagePath ?? this.imagePath, // Use provided 'imagePath' or keep the current 'imagePath'
      description: description ?? this.description, // Use provided 'description' or keep the current 'description'
      timestamp: timestamp ?? this.timestamp, // Use provided 'timestamp' or keep the current 'timestamp'
    );
  }
}
