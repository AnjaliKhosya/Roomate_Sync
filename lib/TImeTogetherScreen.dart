import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'PollScreen.dart';
import 'PlanActivityScreen.dart';
import 'package:roomate_sync/PushNotificationService.dart';

class TimeTogetherScreen extends StatefulWidget {
  final String roomCode;
  const TimeTogetherScreen({Key? key, required this.roomCode}) : super(key: key);

  @override
  _TimeTogetherScreenState createState() => _TimeTogetherScreenState();
}

class _TimeTogetherScreenState extends State<TimeTogetherScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Map<String, String>> activities = [
    {'title': 'Movie Night', 'image': 'assets/images/MovieNight.jpg'},
    {'title': 'Dinner & Cooking', 'image': 'assets/images/Cooking.jpg'},
    {'title': 'Gossip Time', 'image': 'assets/images/Gossip.jpg'},
    {'title': 'Game Night', 'image': 'assets/images/Game.jpg'},
    {'title': 'Outing', 'image': 'assets/images/OutingPicture.jpg'},
    {'title': 'Issue Sharing', 'image': 'assets/images/ -2.jpg'},
    {'title': 'Shopping Together', 'image': 'assets/images/Shopping.jpg'},
    {'title': 'Makeover Night', 'image': 'assets/images/Styling.jpg'},
    {'title': 'Dance & Music Night', 'image': 'assets/images/Dancing.jpg'},
  ];

  final Set<String> selectedActivities = {};

  void toggleSelection(String activity) {
    setState(() {
      if (selectedActivities.contains(activity)) {
        selectedActivities.remove(activity);
      } else {
        selectedActivities.add(activity);
      }
    });
  }

  Future<void> createPoll() async {
    if (selectedActivities.isEmpty) return;

    try {
      await _firestore
          .collection('rooms')
          .doc(widget.roomCode)
          .collection('polls')
          .add({
        'question': "What do you want to do together?",
        'activities': selectedActivities.toList(),
        'options': {for (var activity in selectedActivities) activity: 0},
        'totalVotes': 0,
        'expiry': Timestamp.fromDate(DateTime.now().add(Duration(days: 1))),
        'votedUsers': {},
      });
    } catch (e) {
      print("Error while creating poll: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create poll. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Time Together"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PollScreen(roomCode: widget.roomCode),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.blue.shade50,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(Icons.poll_outlined, size: 36, color: Colors.blue),
                              SizedBox(height: 8),
                              Text("Active Polls", style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlanActivityScreen(roomCode: widget.roomCode),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.green.shade50,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(Icons.event_available, size: 36, color: Colors.green),
                              SizedBox(height: 8),
                              Text("Plan Activity", style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Select activities below to create a poll:",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                final isSelected = selectedActivities.contains(activity['title']);
                return GestureDetector(
                  onTap: () => toggleSelection(activity['title']!),
                  child: Card(
                    color: isSelected ? Colors.blue.shade200 : Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(activity['image']!, height: 60),
                        SizedBox(height: 8),
                        Text(activity['title']!, style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () async {
                  if (selectedActivities.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please select at least one activity")),
                    );
                    return;
                  }

                  await createPoll();

                  await PushNotificationService.sendNotificationToAllRoommates(
                    roomCode: widget.roomCode,
                    title: '🕒 Time Together',
                    body: 'New poll created! Cast your vote now.',
                  );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PollScreen(roomCode: widget.roomCode),
                    ),
                  );
                },
                child: Text("Create Poll"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
