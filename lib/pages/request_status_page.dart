import 'package:flutter/material.dart';
import 'package:savethefood/pages/api_service.dart';
import 'package:savethefood/pages/donor_dashboard.dart';
import 'package:savethefood/pages/recipient_dashboard.dart';
import 'package:savethefood/pages/request_model.dart';
import 'package:savethefood/pages/chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestStatusPage extends StatefulWidget {
  final String userId;
  final String type; // Type of requests to display ('donor' or 'recipient')

  const RequestStatusPage({Key? key, required this.userId, required this.type})
      : super(key: key);

  @override
  _RequestStatusPageState createState() => _RequestStatusPageState();
}

class _RequestStatusPageState extends State<RequestStatusPage> {
  List<Request> userRequests = []; // List to hold the user's requests

  @override
  void initState() {
    super.initState();
    fetchUserRequests(); // Fetch requests when the widget is initialized
  }

  Future<void> fetchUserRequests() async {
    try {
      var requests = await ApiService.getRequests(widget.type);
      var removedRequests = await _getRemovedRequests();

      setState(() {
        userRequests = requests
            .where((request) =>
                request.senderId == widget.userId &&
                !removedRequests.contains(request.id))
            .toList();
      });
    } catch (error) {
      print('Error fetching user requests: $error');
    }
  }

  Future<void> fetchAllRequests() async {
    try {
      var requests = await ApiService.getRequests(widget.type);

      setState(() {
        userRequests = requests
            .where((request) => request.senderId == widget.userId)
            .toList();
      });
    } catch (error) {
      print('Error fetching user requests: $error');
    }
  }

  Future<void> _storeRemovedRequest(String requestId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? removedRequests = prefs.getStringList('removed_requests');
    removedRequests ??= [];
    removedRequests.add(requestId);
    await prefs.setStringList('removed_requests', removedRequests);
  }

  Future<List<String>> _getRemovedRequests() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('removed_requests') ?? [];
  }

  Future<void> completeRequest(String requestId) async {
    try {
      await ApiService.updateStatus(requestId, 'completed');
      setState(() {
        userRequests = userRequests.map((request) {
          if (request.id == requestId) {
            request.status = 'completed';
          }
          return request;
        }).toList();
      });
    } catch (error) {
      print('Error completing request: $error');
    }
  }

  Future<void> rejectRequest(String requestId, String reason) async {
    try {
      await ApiService.updateStatus(requestId, 'rejected', reason: reason);
      setState(() {
        userRequests = userRequests.map((request) {
          if (request.id == requestId) {
            request.status = 'rejected';
          }
          return request;
        }).toList();
      });
    } catch (error) {
      print('Error rejecting request: $error');
    }
  }

  Widget buildRequestCard(Request request) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request ID: ${request.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Details:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: request.details.entries.map((entry) {
                    if (entry.key != 'coordinates') {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }).toList(),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Status:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  request.status,
                  style: TextStyle(
                    fontSize: 14,
                    color: request.status == 'pending'
                        ? Colors.orange
                        : request.status == 'accepted'
                            ? Colors.greenAccent
                            : request.status == 'completed'
                                ? Colors.blue
                                : Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (request.status == 'accepted') ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ElevatedButton(
                      onPressed: () => completeRequest(request.id),
                      child: const Text('Mark as Completed',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _showRejectDialog(request),
                      child: const Text('Reject',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
                if (request.status == 'completed')
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Request Completed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                if (request.status == 'rejected')
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Request Rejected',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
              ],
            ),
            Positioned(
              top: 8.0,
              right: 8.0,
              child: IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () => _removeRequestFromUI(request),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(Request request) {
    TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject Request'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Enter rejection reason',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String reason = reasonController.text.trim();
                if (reason.isNotEmpty) {
                  rejectRequest(request.id, reason);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a reason for rejection'),
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _removeRequestFromUI(Request request) async {
    setState(() {
      userRequests.remove(request);
    });
    await _storeRemovedRequest(request.id);
  }

  void _navigateToChatPage(Request request) {
    if (request.volunteerId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            receiverId: request.volunteerId!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login')),
        title: Text(
            widget.type == 'donor' ? 'Donor Requests' : 'Recipient Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchAllRequests,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => widget.type == 'donor'
                      ? DonorDashboard()
                      : RecipientDashboard(),
                ),
              );
            },
          ),
        ],
      ),
      body: userRequests.isEmpty
          ? Center(child: Text('No requests found'))
          : ListView.builder(
              itemCount: userRequests.length,
              itemBuilder: (context, index) {
                return buildRequestCard(userRequests[index]);
              },
            ),
    );
  }
}
