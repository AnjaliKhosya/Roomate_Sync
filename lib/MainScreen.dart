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
import 'PushNotificationService.dart';
import 'package:intl/intl.dart';

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
    checkAndSendActivityReminders(widget.roomCode);
    sendDeadlineReminders(widget.roomCode);
  }

  Future<void> checkAndSendActivityReminders(String roomCode) async {
    final now = DateTime.now();
    final windowEnd = now.add(const Duration(minutes: 30)); // 30 min window

    final activitySnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomCode)
        .collection('activities')
        .where('notified', isEqualTo: false) // Only check unnotified ones
        .get();

    for (final doc in activitySnapshot.docs) {
      final data = doc.data();
      final scheduledAt = (data['timestamp'] as Timestamp).toDate();

      if (scheduledAt.isAfter(now) && scheduledAt.isBefore(windowEnd)) {
        final title = data['title'] ?? 'Planned Activity';

        // ✅ Send notification to all roommates
        await PushNotificationService.sendNotificationToAllRoommates(
          roomCode: roomCode,
          title: "⏰ Time Together Reminder!",
          body: "Don't forget: $title starts at ${DateFormat.jm().format(scheduledAt)}",
        );

        // ✅ Mark as notified so it’s not sent again
        await doc.reference.update({'notified': true});
      }
    }
  }

  Future<void> sendDeadlineReminders(String roomCode) async {
    try {
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomCode)
          .collection('tasks')
          .get();

      final today = DateTime.now();

      for (final doc in tasksSnapshot.docs) {
        final data = doc.data();
        final String? deadlineStr = data['deadline'];
        final String? assignedTo = data['assignedTo'];
        final String? title = data['title'];
        final bool reminderSent = data['DeadlineReminder'] ?? false;

        if (deadlineStr == null || assignedTo == null || reminderSent) continue;

        // Parse deadline from string format 'dd/MM/yyyy'
        final deadlineDate = DateFormat('dd/MM/yyyy').parse(deadlineStr);
        final isToday = deadlineDate.year == today.year &&
            deadlineDate.month == today.month &&
            deadlineDate.day == today.day;

        if (isToday) {
          // Get FCM token of the assigned roommate
          final userDoc = await FirebaseFirestore.instance
              .collection('rooms')
              .doc(roomCode)
              .collection('Roomates')
              .doc(assignedTo)
              .get();

          final token = userDoc.data()?['FCMToken'];
          if (token != null && token.toString().isNotEmpty) {
            await PushNotificationService.sendNotificationToSelectedRoommate(
              token,
              assignedTo,
              "Task Deadline Reminder 🕒",
              "Hey! Your task \"$title\" is due today. Don't forget to complete it!",
            );

            // 🔁 Mark DeadlineReminder as true
            await doc.reference.update({'DeadlineReminder': true});
          }
        }
      }
    } catch (e) {
      print("Error sending deadline reminders: $e");
    }
  }


  Future<void> fetchProfileImage() async {
    if (user != null) {
      try {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        final data = docSnapshot.data();
        if (data != null) {
          final url = data['profileImage'] as String?;
          if (url != null && url.isNotEmpty) {
            setState(() {
              cloudinaryUrl = url;
            });
            print("Cloudinary URL set: $cloudinaryUrl");
          } else {
            print("profileImage is null or empty.");
          }
        } else {
          print("No document found for user ${user!.uid}");
        }
      } catch (e) {
        print("Error fetching profile image: $e");
      }
    } else {
      print("User is null");
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
              onTap: () async {
                await Get.to(() => ProfileScreen(roomCode: widget.roomCode));
                await fetchProfileImage(); // refresh profile image after returning
              },

              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: (cloudinaryUrl != null && cloudinaryUrl!.isNotEmpty)
                    ? NetworkImage(cloudinaryUrl!)
                    : (user?.photoURL != null && user!.photoURL!.isNotEmpty)
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: (cloudinaryUrl == null &&
                    (user?.photoURL == null || user!.photoURL!.isEmpty))
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
