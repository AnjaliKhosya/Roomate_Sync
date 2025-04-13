import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoommateStatsPage extends StatefulWidget {
  final String roomCode;

  const RoommateStatsPage({Key? key, required this.roomCode}) : super(key: key);

  @override
  _RoommateStatsPageState createState() => _RoommateStatsPageState();
}

class _RoommateStatsPageState extends State<RoommateStatsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background
      appBar: AppBar(
        title: const Text(
          "Roommate Statistics",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.roomCode)
            .collection('Roomates')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No roommates found.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          final roommatesData = snapshot.data!.docs;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 24.0,bottom:24, left: 100),
            child: Column(
              children: roommatesData.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final userName = data['name'] ?? 'Unknown';
                final tasksCompleted = data['taskCompleted'] ?? 0;
                final totalTasks = data['totalTasks'] ?? 1;
                final percentage = totalTasks > 0 ? tasksCompleted / totalTasks : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: CircularProgressIndicator(
                              value: percentage,
                              strokeWidth: 10,
                              backgroundColor: Colors.grey[800],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                percentage > 0.75
                                    ? Colors.greenAccent
                                    : percentage > 0.5
                                    ? Colors.amber
                                    : Colors.redAccent,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "$tasksCompleted / $totalTasks",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
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
