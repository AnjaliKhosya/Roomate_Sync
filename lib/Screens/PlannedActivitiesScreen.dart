import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:roomate_sync/Screens/PlanActivityScreen.dart'; // Ensure this path is correct

class PlannedActivitiesScreen extends StatelessWidget {
  final String roomCode;

  const PlannedActivitiesScreen({Key? key, required this.roomCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B0B45),
      appBar: AppBar(
        title: const Text('Planned Activities'),
        backgroundColor: const Color(0xFF0B0B45),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .doc(roomCode)
            .collection('activities')
            .orderBy('timestamp')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No activities planned yet.'));
          }

          final activities = snapshot.data!.docs;

          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final data = activities[index].data() as Map<String, dynamic>;
              final timestamp = (data['timestamp'] as Timestamp).toDate().toLocal();
              final formattedDate = DateFormat.yMMMMd().format(timestamp);
              final formattedTime = DateFormat.jm().format(timestamp);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.event_note, color: Color(0xFF0B0B45)),
                  title: Text(
                    data['title'] ?? 'Untitled Activity',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('$formattedDate at $formattedTime'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlanActivityScreen(roomCode: roomCode),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white,size: 35,),
      ),
    );
  }
}
