import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_model.dart';
import 'notification_management.dart'; // Import the SendNotification class for sending notifications

// ChatPage widget to display and manage chat conversations
class ChatPage extends StatefulWidget {
  final String receiverId; // ID of the user with whom the chat is taking place

  // Constructor to receive receiverId
  ChatPage({required this.receiverId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController(); // Controller for the message input field
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance of FirebaseAuth for authentication
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instance of FirebaseFirestore for database operations

  late String chatId; // Variable to hold the unique chat ID
  String? receiverName; // Variable to hold the name of the receiver
  late SendNotification sendNotification; // Instance of SendNotification for sending notifications

  @override
  void initState() {
    super.initState();
    _generateOrFetchChatId(); // Generate or fetch the chat ID when the widget initializes
    _fetchReceiverName(); // Fetch the receiver's name when the widget initializes
    sendNotification = SendNotification(); // Initialize the SendNotification instance
  }

  // Method to fetch the receiver's name from Firestore
  Future<void> _fetchReceiverName() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.receiverId)
        .get();
    setState(() {
      receiverName = userDoc['username']; // Set the receiver's name from the Firestore document
    });
  }

  // Method to generate or fetch the chat ID based on the current and receiver user IDs
  Future<void> _generateOrFetchChatId() async {
    final user = _auth.currentUser;
    if (user == null) return; // Return if the user is not authenticated

    String currentUserId = user.uid; // Get the current user's ID
    String otherUserId = widget.receiverId; // Get the receiver's ID

    // Generate a unique chat ID based on the sorted user IDs
    List<String> userIds = [currentUserId, otherUserId];
    userIds.sort(); // Sort user IDs to ensure a consistent chat ID
    chatId = userIds.join('_'); // Create a chat ID by joining sorted user IDs with an underscore

    // Check if the chat document already exists
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();

    if (!chatDoc.exists) {
      // Create a new chat document if it does not exist
      await _firestore.collection('chats').doc(chatId).set({
        'users': [currentUserId, otherUserId], // Set the participants of the chat
      });
    }
  }

  // Method to send a message in the chat
  void _sendMessage() async {
    final user = _auth.currentUser;
    if (user == null) return; // Return if the user is not authenticated

    final message = _messageController.text; // Get the message text from the controller
    if (message.trim().isEmpty) return; // Return if the message is empty

    final chatMessage = ChatMessage(
      senderId: user.uid, // Sender's ID
      receiverId: widget.receiverId, // Receiver's ID
      message: message, // The message text
      timestamp: Timestamp.now(), // The current timestamp
    );

    // Add the message to the chat's messages collection in Firestore
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(chatMessage.toMap());

    // Send notification to the receiver
    String receiverToken = ''; // Fetch the receiver's token from Firestore (this needs to be implemented)
    sendNotification.sendTextMessageNotification(
      textMsg: message,
      connectionToken: receiverToken,
      currAccountUserName: user.displayName ?? 'Anonymous', // Use 'Anonymous' if displayName is null
    );

    print(">>>>>>>>>>>>>>>>>>>>>");
    print(user.displayName);

    _messageController.clear(); // Clear the message input field after sending
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $receiverName'), // Display the receiver's name in the AppBar
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(), // Stream messages sorted by timestamp
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator()); // Show a loading indicator while fetching data
                }

                final messages = snapshot.data!.docs
                    .map((doc) => ChatMessage.fromDocument(doc)) // Map Firestore documents to ChatMessage objects
                    .toList();

                return ListView.builder(
                  reverse: true, // Display the most recent messages at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _auth.currentUser?.uid; // Check if the message is from the current user

                    return ListTile(
                      title: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, // Align message based on sender
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75, // Limit message width to 75% of screen width
                          ),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue : Colors.grey, // Set message background color based on sender
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              message.message, // Display the message text
                              style: TextStyle(color: Colors.white), // Set text color to white
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController, // Controller for the message input field
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your message...', // Hint text for the input field
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send), // Icon for the send button
                  onPressed: _sendMessage, // Call _sendMessage when the button is pressed
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
