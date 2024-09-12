import 'package:flutter/material.dart';

//display error msg to user
void displayMessageToUser(String message, BuildContext context) {
  final snackBar = SnackBar(content: Text(message));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(message),
    ),
  );
}
