import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roomate_sync/Screens/PollScreen.dart';
import 'package:roomate_sync/Screens/PlannedActivitiesScreen.dart';
import 'package:roomate_sync/services/PushNotificationService.dart';

class TimeTogetherScreen extends StatefulWidget {
  final String roomCode;
  const TimeTogetherScreen({Key? key, required this.roomCode}) : super(key: key);

  @override
  _TimeTogetherScreenState createState() => _TimeTogetherScreenState();
}

class _TimeTogetherScreenState extends State<TimeTogetherScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> activities = [
    {'title': 'Movie Night', 'image': 'assets/images/Movie.jpg', 'width': 180.0, 'height': 130.0},
    {'title': 'Dinner & Cooking', 'image': 'assets/images/Cooking.jpg', 'width': 140.0, 'height': 120.0},
    {'title': 'Gossip Time', 'image': 'assets/images/Gossip.jpg', 'width': 150.0, 'height': 100.0},
    {'title': 'Game Night', 'image': 'assets/images/Game.jpg', 'width': 120.0, 'height': 120.0},
    {'title': 'Outing', 'image': 'assets/images/OutingPicture.jpg', 'width': 100.0, 'height': 100.0},
    {'title': 'Issue Sharing', 'image': 'assets/images/ -2.jpg', 'width': 120.0, 'height': 120.0},
    {'title': 'Shopping Together', 'image': 'assets/images/Shopping.jpg', 'width': 150.0, 'height': 120.0},
    {'title': 'Makeover Night', 'image': 'assets/images/ -4.jpg', 'width': 100.0, 'height': 100.0},
    {'title': 'Dance & Music Night', 'image': 'assets/images/Dancing.jpg', 'width': 140.0, 'height': 120.0},
    {'title': 'Digital Detox Day', 'image': 'assets/images/Premium Vector | Digital detox and meditation_ Woman meditating in lotus pose.jpg', 'width': 150.0, 'height': 110.0},
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
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text("Time Together", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF121212),
        iconTheme: IconThemeData(color: Colors.white),
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
                        color: Colors.blue.shade100,
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
                            builder: (context) => PlannedActivitiesScreen(roomCode: widget.roomCode), // ✅ Updated navigation
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.green.shade100,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(Icons.event_note_outlined, size: 36, color: Colors.green),
                              SizedBox(height: 8),
                              Text("Planned Activities", style: TextStyle(fontWeight: FontWeight.w600)), // ✅ Updated label
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
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
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
                final double w = activity['width'] as double;
                final double ht = activity['height'] as double;

                return GestureDetector(
                  onTap: () => toggleSelection(activity['title']!),
                  child: Card(
                    color: isSelected ? Colors.blue : Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: w,
                            height: ht,
                            child: Image.asset(
                              activity['image']!,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Text(activity['title']!, style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.only(left: 130, bottom: 30,top: 20),
              child: Container(
                height: 45 ,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor: Colors.green,
                  ),
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
                  child: Text("Create Poll", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
