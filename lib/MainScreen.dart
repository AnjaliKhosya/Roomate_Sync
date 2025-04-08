import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:roomate_sync/NewTaskScreen.dart';
import 'package:roomate_sync/loginScreen.dart';
import 'ExpenseScreen.dart';
import 'NewExpenseScreen.dart';
import 'Statistics.dart';
import 'Tasks.dart';
import 'ProfileScreen.dart';
import 'CameraScreen.dart';
import 'AlbumScreen.dart';
import 'TimeTogetherScreen.dart';

class MainScreen extends StatefulWidget {
  final String roomCode;

  const MainScreen({Key? key, required this.roomCode}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String? cloudinaryUrl;

  @override
  void initState() {
    super.initState();
    fetchProfileImage();
  }

  Future<void> fetchProfileImage() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (doc.exists && doc.data()?['photoUrl'] != null) {
        setState(() {
          cloudinaryUrl = doc['photoUrl'];
        });
      }
    }
  }

  final List<Map<String, dynamic>> menu = [
    {'title': 'Tasks', 'icon': FontAwesomeIcons.tasks, 'image': 'assets/images/Tasks.jpeg'},
    {'title': 'Add Task', 'icon': FontAwesomeIcons.plus, 'image': 'assets/images/AddTask.jpeg'},
    {'title': 'Expenses', 'icon': FontAwesomeIcons.coins, 'image': 'assets/images/Expenses.jpeg'},
    {'title': 'Add Expense', 'icon': FontAwesomeIcons.plus, 'image': 'assets/images/AddExpenses.jpeg'},
    {'title': 'Statistics', 'icon': FontAwesomeIcons.chartPie, 'image': 'assets/images/Stats.jpeg'},
    {'title': 'Camera', 'icon': FontAwesomeIcons.camera, 'image': 'assets/images/Camera.jpg'},
    {'title': 'Album', 'icon': FontAwesomeIcons.images, 'image': 'assets/images/Gallery.jpg'},
    {'title': 'Time Together', 'icon': FontAwesomeIcons.users, 'image': 'assets/images/TimeTogether.jpg'},
  ];

  void navigateToPage(String title) {
    switch (title) {
      case 'Tasks':
        Navigator.push(context, MaterialPageRoute(builder: (context) => TaskScreen(roomCode: widget.roomCode)));
        break;
      case 'Add Task':
        Navigator.push(context, MaterialPageRoute(builder: (context) => NewTaskScreen(roomCode: widget.roomCode)));
        break;
      case 'Expenses':
        Navigator.push(context, MaterialPageRoute(builder: (context) => ExpenseScreen(roomCode: widget.roomCode)));
        break;
      case 'Add Expense':
        Navigator.push(context, MaterialPageRoute(builder: (context) => NewExpenseScreen(roomCode: widget.roomCode)));
        break;
      case 'Statistics':
        Navigator.push(context, MaterialPageRoute(builder: (context) => RoommateStatsPage(roomCode: widget.roomCode)));
        break;
      case 'Camera':
        Navigator.push(context, MaterialPageRoute(builder: (context) => CameraScreen(roomCode: widget.roomCode)));
        break;
      case 'Album':
        Navigator.push(context, MaterialPageRoute(builder: (context) => AlbumScreen(roomCode: widget.roomCode)));
        break;
      case 'Time Together':
        Navigator.push(context, MaterialPageRoute(builder: (context) => TimeTogetherScreen(roomCode: widget.roomCode)));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B45),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B45),
        title: const Text(
          'Hey Roomie 👋',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () => Get.to(() => ProfileScreen(roomCode: widget.roomCode)),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: (cloudinaryUrl != null || user?.photoURL != null)
                    ? NetworkImage(cloudinaryUrl ?? user!.photoURL!)
                    : null,
                child: (cloudinaryUrl == null && user?.photoURL == null)
                    ? const Icon(Icons.person, size: 24, color: Colors.black)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: menu.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => navigateToPage(menu[index]['title']),
              child: Card(
                color: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(menu[index]['image'], height: 100, fit: BoxFit.cover),
                    const SizedBox(height: 8),
                    Text(
                      menu[index]['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
