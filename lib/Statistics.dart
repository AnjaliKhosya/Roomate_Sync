import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoommateStatsPage extends StatefulWidget {
  final String roomCode; // Pass the room code to this page.

  const RoommateStatsPage({Key? key, required this.roomCode}) : super(key: key);

  @override
  _RoommateStatsPageState createState() => _RoommateStatsPageState();
}

class _RoommateStatsPageState extends State<RoommateStatsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Roommate Statistics"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.roomCode)
            .collection('Roomates')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No roommates found."));
          }

          final roommatesData = snapshot.data!.docs;

          return SingleChildScrollView(
            child: Column(
              children: roommatesData.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final userName = data['name'] ?? 'Unknown';
                final tasksCompleted = data['taskCompleted'] ?? 0;
                final totalTasks = data['totalTasks'] ?? 1;
                final percentage = totalTasks > 0 ? tasksCompleted / totalTasks : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(left: 100.0,top: 50),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Circular Progress Indicator
                          SizedBox(
                            width: 170,
                            height: 170,
                            child: CircularProgressIndicator(
                              value: percentage,
                              strokeWidth: 12,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                percentage > 0.75
                                    ? Colors.green
                                    : percentage > 0.5
                                    ? Colors.yellow
                                    : Colors.red,
                              ),
                            ),
                          ),
                          // Task Stats and User Name
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "$tasksCompleted/$totalTasks",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                userName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}


