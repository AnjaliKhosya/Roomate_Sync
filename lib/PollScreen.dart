import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'TimeTogetherScreen.dart';

class PollScreen extends StatefulWidget {
  final String roomCode;
  const PollScreen({Key? key, required this.roomCode}) : super(key: key);

  @override
  _PollScreenState createState() => _PollScreenState();
}

class _PollScreenState extends State<PollScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid ?? "anonymous";

  void vote(String pollId, String option) async {
    final pollRef = FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomCode)
        .collection('polls')
        .doc(pollId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(pollRef);
      if (!snapshot.exists) return;

      final pollData = snapshot.data() as Map<String, dynamic>;
      final options = Map<String, dynamic>.from(pollData['options'] ?? {});
      final votedUsers = Map<String, dynamic>.from(pollData['votedUsers'] ?? {});

      if (votedUsers.containsKey(userId)) return;

      if (options.containsKey(option)) {
        options[option] = (options[option] as int) + 1;
        votedUsers[userId] = option;

        transaction.update(pollRef, {
          'options': options,
          'votedUsers': votedUsers,
        });
      }
    });
  }

  void deletePoll(BuildContext context, String pollId) async {
    final pollRef = FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomCode)
        .collection('polls')
        .doc(pollId);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Poll"),
        content: Text("Are you sure you want to delete this poll?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      await pollRef.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TimeTogetherScreen(roomCode: widget.roomCode)),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text("Active Polls")),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('rooms')
              .doc(widget.roomCode)
              .collection('polls')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("No active polls"));
            }

            final polls = snapshot.data!.docs;
            final currentTime = DateTime.now();

            return ListView(
              children: polls.map((poll) {
                final pollData = poll.data() as Map<String, dynamic>;
                final expiry = (pollData['expiry'] as Timestamp?)?.toDate() ?? DateTime.now();
                if (expiry.isBefore(currentTime)) return SizedBox();

                final options = Map<String, dynamic>.from(pollData['options'] ?? {});
                final votedUsers = Map<String, dynamic>.from(pollData['votedUsers'] ?? {});
                final totalVotes = options.values.fold(0, (sum, value) => sum + (value as int));
                final hasVoted = votedUsers.containsKey(userId);

                return Card(
                  margin: EdgeInsets.all(12),
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pollData['question'] ?? "Untitled Poll",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12),
                        Column(
                          children: options.entries.map((entry) {
                            final percentage = totalVotes > 0
                                ? (entry.value / totalVotes) * 100
                                : 0.0;
                            final isSelected = votedUsers[userId] == entry.key;

                            return ListTile(
                              title: Text(entry.key),
                              subtitle: LinearProgressIndicator(value: percentage / 100),
                              trailing: Text("${entry.value} votes"),
                              tileColor: isSelected ? Colors.green.withOpacity(0.1) : null,
                              onTap: hasVoted
                                  ? null
                                  : () => vote(poll.id, entry.key),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Expires on: ${DateFormat('yyyy-MM-dd HH:mm').format(expiry)}"),
                                  if (hasVoted)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        "You have already voted.",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.black),
                              onPressed: () => deletePoll(context, poll.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

}
