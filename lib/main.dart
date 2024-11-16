import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pg2_app/screens/splash.dart';
import 'firebase_options.dart'; // Make sure to import your generated Firebase options
import 'package:pg2_app/screens/auth.dart';
import 'package:pg2_app/screens/profile.dart';
import 'package:pg2_app/screens/Searchscreen.dart'; // Import SearchScreen
import 'package:pg2_app/Screens/ChatScreen.dart';
import 'package:pg2_app/Screens/ChatList.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const splashScreen();
          }
          if (snapshot.hasData) {
            return HomeScreen(); // Navigate to HomeScreen after login
          }
          return AuthScreen(); // Show AuthScreen if not logged in
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Define the current index for bottom navigation
  int _selectedIndex = 0;

  // List of screens for navigation, with ProfileScreen at index 1 (right) and SearchScreen at index 0 (left)
  final List<Widget> _screens = [
    ChatList(),
    SearchScreen(),  // Search page (left)
    ProfileScreen(), // Profile page (right)
  ];

  // Handle navigation bar item selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   //   appBar: AppBar(title: const Text("Welcome to MyApp")),
      body: _screens[_selectedIndex], // Display selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
