import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:savethefood/pages/request_model.dart';

// ApiService class to handle API interactions related to requests and chats
class ApiService {
  // Reference to the 'requests' node in Firebase Realtime Database
  static final DatabaseReference _requestsRef =
      FirebaseDatabase.instance.ref().child('requests');

  // Method to submit a new request
  static Future<void> submitRequest(Map<String, dynamic> requestData) async {
    try {
      final senderId = requestData['senderId'];
      print("API");

      // Fetch all requests for the sender from the Firebase Realtime Database
      final snapshot =
          await _requestsRef.orderByChild('senderId').equalTo(senderId).once();

      print('Snapshot data: ${snapshot.snapshot.value}');

      if (snapshot.snapshot.exists) {
        final requests = snapshot.snapshot.children;

        // Check if there are any pending requests
        bool hasPendingRequest = requests.any((r) {
          final requestData = r.value as Map?;
          return requestData != null && requestData['status'] == 'pending';
        });

        // If there is a pending request, throw an exception
        if (hasPendingRequest) {
          throw Exception("You already have a pending request.");
        }
      }

      // Push the new request to Firebase Realtime Database
      await _requestsRef.child(requestData['id']).set(requestData);
    } catch (error) {
      print('Error submitting request: $error');
      throw error; // Rethrow the error to be handled by the caller
    }
  }

  // Method to fetch requests based on their type
  static Future<List<Request>> getRequests(String type) async {
    try {
      // Query the requests node to get requests of a specific type
      final snapshot =
          await _requestsRef.orderByChild('type').equalTo(type).once();

      final requests = <Request>[]; // List to hold fetched requests
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        data.forEach((key, value) {
          final map = Map<String, dynamic>.from(value as Map<dynamic, dynamic>);
          final request = Request.fromMap(map); // Convert map to Request object

          requests.add(request); // Add request to the list
        });
      }

      return requests; // Return the list of requests
    } catch (error) {
      print('Error fetching requests: $error');
      throw error; // Rethrow the error to be handled by the caller
    }
  }

  // Method to accept a request and assign it to a volunteer
  static Future<void> acceptRequest(
      String requestId, String volunteerId) async {
    try {
      print("Accept Pressed");

      // Reference to the specific request in Firebase Realtime Database
      final requestRef = _requestsRef.child(requestId);
      print(requestId);

      // Update the request status to 'accepted' and set the volunteer ID
      await requestRef.update({
        'status': 'accepted',
        'volunteerId': volunteerId,
      });

      print('Request updated in Firebase: $requestId');
    } catch (error) {
      print('Error accepting request: $error');
      throw error; // Rethrow the error to be handled by the caller
    }
  }

  // Method to update the status of a request, with an optional reason
  static Future<void> updateStatus(String requestId, String status,
      {String? reason}) async {
    try {
      // Reference to the specific request in Firebase Realtime Database
      final requestRef = _requestsRef.child(requestId);
      Map<String, dynamic> updateData = {
        'status': status, // Update the status of the request
      };

      if (reason != null) {
        updateData['reason'] = reason; // Add reason if provided
      }

      // Update the request in Firebase Realtime Database
      await requestRef.update(updateData);
      print('Request status updated in Firebase: $requestId to $status');
    } catch (error) {
      print('Error updating request status: $error');
      throw error; // Rethrow the error to be handled by the caller
    }
  }

  // Method to fetch a user's request based on their user ID
  static Future<Request?> getUserRequest(String userId) async {
    try {
      // Query the requests node to get requests for the specific user
      final snapshot =
          await _requestsRef.orderByChild('senderId').equalTo(userId).once();

      // Get the first request if available
      final requestData = snapshot.snapshot.children.isNotEmpty
          ? Map<String, dynamic>.from(
              snapshot.snapshot.children.first.value as Map)
          : null;

      // Return the request as a Request object if available
      return requestData != null ? Request.fromMap(requestData) : null;
    } catch (error) {
      print('Error fetching user request: $error');
      throw error; // Rethrow the error to be handled by the caller
    }
  }

  // Method to get or create a chat ID between a volunteer and a sender
  static Future<String> getOrCreateChatId(
      String volunteerId, String senderId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    String chatId = '';

    // Check if a chat document already exists between the two users
    final chatQuery = await firestore
        .collection('chats')
        .where('participants', arrayContainsAny: [volunteerId, senderId]).get();

    if (chatQuery.docs.isNotEmpty) {
      // If a chat exists, return the existing chat ID
      chatId = chatQuery.docs.first.id;
    } else {
      // If no chat exists, create a new chat document
      final newChatRef = await firestore.collection('chats').add({
        'participants': [volunteerId, senderId], // Participants of the chat
        'createdAt': Timestamp.now(), // Timestamp when the chat was created
      });

      chatId = newChatRef.id; // Get the ID of the newly created chat document
    }

    return chatId; // Return the chat ID
  }
}
