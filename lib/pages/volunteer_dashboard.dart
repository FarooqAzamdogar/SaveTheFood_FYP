import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:savethefood/pages/profile_page.dart';
import 'package:savethefood/pages/api_service.dart';
import 'package:savethefood/pages/chat_page.dart';
import 'package:savethefood/pages/request_model.dart';
import 'package:url_launcher/url_launcher.dart';

class VolunteerDashboard extends StatefulWidget {
  const VolunteerDashboard({Key? key}) : super(key: key);

  @override
  _VolunteerDashboardState createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard> {
  // Maps to hold the donor and recipient requests categorized by status
  Map<String, List<Request>> donorRequests = {};
  Map<String, List<Request>> recipientRequests = {};
  // Maps to manage the expanded state of request sections
  Map<String, List<bool>> donorExpanded = {};
  Map<String, List<bool>> recipientExpanded = {};

  bool isLoading = true; // Flag to indicate loading state

  @override
  void initState() {
    super.initState();
    fetchRequests(); // Fetch requests when the widget is initialized
  }

  // Fetch username from Firestore based on user ID
  Future<String> fetchUsername(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return userDoc['username'];
    } catch (e) {
      print('Error fetching username: $e');
      return 'Unknown'; // Fallback username in case of an error
    }
  }

  // Fetch donor and recipient requests and populate the maps
  void fetchRequests() async {
    setState(() {
      isLoading = true; // Set loading state
    });

    // Fetch donor and recipient requests using ApiService
    var donors = await ApiService.getRequests('donor');
    var recipients = await ApiService.getRequests('recipient');

    // Map to hold usernames
    Map<String, String> usernames = {};

    // Fetch usernames for all request senders
    for (var request in donors) {
      if (!usernames.containsKey(request.senderId)) {
        usernames[request.senderId] = await fetchUsername(request.senderId);
      }
    }

    for (var request in recipients) {
      if (!usernames.containsKey(request.senderId)) {
        usernames[request.senderId] = await fetchUsername(request.senderId);
      }
    }

    // Populate donorRequests map with categorized requests
    setState(() {
      donorRequests = {
        'pending': donors
            .where((req) => req.status == 'pending')
            .map((req) => req.copyWith(username: usernames[req.senderId]))
            .toList(),
        'accepted': donors
            .where((req) => req.status == 'accepted')
            .map((req) => req.copyWith(username: usernames[req.senderId]))
            .toList(),
        'completed': donors
            .where((req) => req.status == 'completed')
            .map((req) => req.copyWith(username: usernames[req.senderId]))
            .toList(),
        'rejected': donors
            .where((req) => req.status == 'rejected')
            .map((req) => req.copyWith(username: usernames[req.senderId]))
            .toList(),
      };
      // Populate recipientRequests map with categorized requests
      recipientRequests = {
        'pending': recipients
            .where((req) => req.status == 'pending')
            .map((req) => req.copyWith(username: usernames[req.senderId]))
            .toList(),
        'accepted': recipients
            .where((req) => req.status == 'accepted')
            .map((req) => req.copyWith(username: usernames[req.senderId]))
            .toList(),
        'completed': recipients
            .where((req) => req.status == 'completed')
            .map((req) => req.copyWith(username: usernames[req.senderId]))
            .toList(),
        'rejected': recipients
            .where((req) => req.status == 'rejected')
            .map((req) => req.copyWith(username: usernames[req.senderId]))
            .toList(),
      };

      // Initialize expanded state for each request category
      donorExpanded = {
        'pending': List<bool>.filled(donorRequests['pending']!.length, false),
        'accepted': List<bool>.filled(donorRequests['accepted']!.length, false),
        'completed':
            List<bool>.filled(donorRequests['completed']!.length, false),
        'rejected': List<bool>.filled(donorRequests['rejected']!.length, false),
      };
      recipientExpanded = {
        'pending':
            List<bool>.filled(recipientRequests['pending']!.length, false),
        'accepted':
            List<bool>.filled(recipientRequests['accepted']!.length, false),
        'completed':
            List<bool>.filled(recipientRequests['completed']!.length, false),
        'rejected':
            List<bool>.filled(recipientRequests['rejected']!.length, false),
      };

      isLoading = false; // Set loading state to false after fetching
    });
  }

  // Accept a request and create a chat if needed
  void acceptRequest(Request request) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user is currently signed in.');
      return;
    }
    String userId = user.uid;
    await ApiService.acceptRequest(request.id, userId);

    // Create or get chat ID for the accepted request
    // ignore: unused_local_variable
    String chatId =
        await ApiService.getOrCreateChatId(userId, request.senderId);
    fetchRequests(); // Refresh the request list
  }

  // Mark a request as completed
  Future<void> completeRequest(String requestId) async {
    await ApiService.updateStatus(requestId, 'completed');
    fetchRequests(); // Refresh the request list
  }

  // Reject a request with a reason
  Future<void> rejectRequest(String requestId, String reason) async {
    await ApiService.updateStatus(requestId, 'rejected', reason: reason);
    fetchRequests(); // Refresh the request list
  }

  // Launch a URL in an external application
  void _launchUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error launching URL: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Text('Volunteer Dashboard', style: TextStyle(color: Colors.white)),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while fetching
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Donor Requests',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.black),
                    ),
                    Divider(
                      color: Theme.of(context)
                          .dividerColor, // Color of the divider
                      thickness: 1, // Thickness of the divider
                    ),
                    // Build request sections for different statuses
                    buildRequestSection(
                      'Pending:',
                      donorRequests['pending'] ?? [],
                      donorExpanded['pending'] ?? [],
                      acceptRequest,
                      completeRequest,
                      rejectRequest,
                    ),
                    buildRequestSection(
                      'Accepted:',
                      donorRequests['accepted'] ?? [],
                      donorExpanded['accepted'] ?? [],
                      acceptRequest,
                      completeRequest,
                      rejectRequest,
                    ),
                    buildRequestSection(
                      'Completed:',
                      donorRequests['completed'] ?? [],
                      donorExpanded['completed'] ?? [],
                      acceptRequest,
                      completeRequest,
                      rejectRequest,
                    ),
                    buildRequestSection(
                      'Rejected:',
                      donorRequests['rejected'] ?? [],
                      donorExpanded['rejected'] ?? [],
                      acceptRequest,
                      completeRequest,
                      rejectRequest,
                    ),
                    const SizedBox(height: 20),
                    //                Divider(
                    //   color: Theme.of(context).dividerColor, // Color of the divider
                    //   thickness: 1, // Thickness of the divider
                    //   indent: 0, // Indent from the start
                    //   endIndent: 0, // Indent from the end
                    // ),
                    Text('Recipient Requests',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: Colors.black)),
                    Divider(
                      color: Theme.of(context)
                          .dividerColor, // Color of the divider
                      thickness: 1, // Thickness of the divider
                      indent: 0, // Indent from the start
                      endIndent: 0, // Indent from the end
                    ),
                    buildRequestSection(
                      'Pending:',
                      recipientRequests['pending'] ?? [],
                      recipientExpanded['pending'] ?? [],
                      acceptRequest,
                      completeRequest,
                      rejectRequest,
                    ),
                    buildRequestSection(
                      'Accepted:',
                      recipientRequests['accepted'] ?? [],
                      recipientExpanded['accepted'] ?? [],
                      acceptRequest,
                      completeRequest,
                      rejectRequest,
                    ),
                    buildRequestSection(
                      'Completed:',
                      recipientRequests['completed'] ?? [],
                      recipientExpanded['completed'] ?? [],
                      acceptRequest,
                      completeRequest,
                      rejectRequest,
                    ),
                    buildRequestSection(
                      'Rejected:',
                      recipientRequests['rejected'] ?? [],
                      recipientExpanded['rejected'] ?? [],
                      acceptRequest,
                      completeRequest,
                      rejectRequest,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfilePage()),
                          );
                        },
                        child: const Text("Go to Profile"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildRequestSection(
    String title,
    List<Request> requests,
    List<bool> expanded,
    void Function(Request) acceptRequest,
    Future<void> Function(String) completeRequest,
    Future<void> Function(String, String) rejectRequest,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.grey[800])),
        ),
        ListView.builder(
          itemCount: requests.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return buildRequestRow(
              requests[index],
              expanded[index],
              () {
                setState(() {
                  expanded[index] = !expanded[index];
                });
              },
              acceptRequest,
              completeRequest,
              rejectRequest,
            );
          },
        ),
      ],
    );
  }

  Widget buildRequestRow(
    Request request,
    bool isExpanded,
    void Function() onExpand,
    void Function(Request) acceptRequest,
    Future<void> Function(String) completeRequest,
    Future<void> Function(String, String) rejectRequest,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: ExpansionTile(
        onExpansionChanged: (expanded) {
          onExpand();
        },
        title: Row(
          children: [
            Expanded(
              child: Text(
                request.username ?? 'Unknown',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            Text(
              request.status,
              style: TextStyle(
                color: request.status == 'accepted'
                    ? Colors.green
                    : request.status == 'pending'
                        ? Colors.orange
                        : request.status == 'completed'
                            ? Colors.blue
                            : Colors.red,
              ),
            ),
          ],
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: request.details.entries.map((entry) {
              if (entry.key != 'coordinates') {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 16.0),
                  child: Text('${entry.key}: ${entry.value}',
                      style: const TextStyle(
                          color: Color.fromARGB(255, 2, 17, 57))),
                );
              }
              return const SizedBox.shrink();
            }).toList(),
          ),
          if (request.status == 'pending')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () => acceptRequest(request),
                  child: const Text('Accept'),
                ),
              ],
            ),
          if (request.status == 'accepted')
            Wrap(
              spacing: 8.0, // Space between buttons
              runSpacing: 8.0, // Space between lines
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          receiverId: request.senderId,
                        ),
                      ),
                    );
                  },
                  child: const Text('Chat'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () => completeRequest(request.id),
                  child: const Text('Complete'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.grey[400],
                  ),
                  onPressed: () async {
                    String? reason = await _showRejectReasonDialog();
                    if (reason != null) {
                      rejectRequest(request.id, reason);
                    }
                  },
                  child: const Text('Reject'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () async {
                    final coordinates = request.details['coordinates']
                        ?.split(',')
                        .map((e) => e.trim())
                        .toList();
                    if (coordinates != null && coordinates.length == 2) {
                      final lat = coordinates[0];
                      final lng = coordinates[1];
                      final url =
                          'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                      _launchUrl(context, url);
                    }
                  },
                  child: const Text('Find Location'),
                ),
              ],
            ),
        ],
        initiallyExpanded: isExpanded,
      ),
    );
  }

  Future<String?> _showRejectReasonDialog() async {
    String? reason;
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reject Request'),
          content: TextField(
            onChanged: (value) {
              reason = value;
            },
            decoration:
                const InputDecoration(hintText: 'Enter rejection reason'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop(reason);
              },
            ),
          ],
        );
      },
    );
    return reason;
  }
}
