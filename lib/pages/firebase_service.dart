import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  Future<void> submitRequest(Map<String, dynamic> requestData) async {
    await _databaseReference.child('requests').push().set(requestData);
  }

  Future<List<Map<String, dynamic>>> fetchRequests() async {
    DatabaseEvent event = await _databaseReference.child('requests').once();
    DataSnapshot snapshot = event.snapshot;
    List<Map<String, dynamic>> requests = [];
    if (snapshot.value != null) {
      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        requests.add(Map<String, dynamic>.from(value));
      });
    }
    return requests;
  }
}
