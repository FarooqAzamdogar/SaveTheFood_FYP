import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyMap extends StatelessWidget {
  const MyMap({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Consumer(
        builder: (context, value, child) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //heading
              Padding(
                padding: EdgeInsets.all(10.0),
                child: SafeArea(
                  child: Text(
                    'My Map',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
