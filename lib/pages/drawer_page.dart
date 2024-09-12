import 'package:savethefood/components/bottom_nav_bar.dart';
import 'package:savethefood/pages/intro_page.dart';
import 'package:flutter/material.dart';
import 'package:savethefood/pages/map_page.dart';
import 'profile_page.dart';
import 'home_page.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({Key? key}) : super(key: key);

  @override
  State<DrawerPage> createState() => _HomePageState();
}

class _HomePageState extends State<DrawerPage> {
  int _selectedIndex = 0;
  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    HomePage(),
    const MyMap(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Scaffold.of(context).isDrawerOpen) {
          Navigator.of(context).pop(); // Close the drawer if it's open
          return false; // Don't pop the route
        }
        return true; // Pop the route
      },
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        bottomNavigationBar: MyBottomNavBar(
          onTabChange: (index) => navigateBottomBar(index),
        ),
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: SafeArea(
              child: Text(
                'SaveTheFood',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(builder: (context) {
            return IconButton(
              icon: Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Image.asset(
                  'lib/img/stf.png',
                  color: Colors.grey,
                  //colorBlendMode: BlendMode.colorDodge,
                ),
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          }),
        ),
        drawer: Drawer(
          backgroundColor: Colors.grey[900],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  DrawerHeader(
                    child: Image.asset(
                      'lib/img/stf.png',
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Divider(
                      color: Colors.grey[800],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      //navigate to home page
                      Navigator.of(context).pop(); // Close the drawer
                      setState(() {
                        _selectedIndex = 0; // Update the selected index
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: ListTile(
                        leading: Icon(
                          Icons.home,
                          color: Colors.white,
                        ),
                        title: Text(
                          'Home',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      //navigate to info page
                      Navigator.of(context).pop(); // Close the drawer
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProfilePage(),
                      ));
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: ListTile(
                        leading: Icon(
                          Icons.info,
                          color: Colors.white,
                        ),
                        title: Text(
                          'About',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  //navigate to intro page
                  Navigator.of(context).pop(); // Close the drawer
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const IntroPage(),
                  ));
                },
                child: const Padding(
                  padding: EdgeInsets.only(
                    left: 25.0,
                    bottom: 25,
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: _pages[_selectedIndex],
      ),
    );
  }
}
