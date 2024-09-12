import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyBottomNavBar extends StatelessWidget {
  final void Function(int)? onTabChange;

  const MyBottomNavBar({
    super.key,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: GNav(
        color: Color.fromARGB(255, 126, 126, 126),
        activeColor: Colors.grey.shade700,
        mainAxisAlignment: MainAxisAlignment.center,
        tabBorderRadius: 20,
        onTabChange: (value) => onTabChange!(value),
        tabs: const [
          GButton(
            icon: Icons.home_rounded,
            text: 'Home',
            iconSize: 16,
          ),
          GButton(
            icon: Icons.login,
            text: 'Login',
            iconSize: 16,
          ),
          // Add other buttons here
        ],
      ),
    );
  }
}
