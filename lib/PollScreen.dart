import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roomate_sync/TimeTogetherScreen.dart'; // adjust the path if needed

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
        title: Text("Delete Poll", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete this poll?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await pollRef.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF0B0B45);
    final Color background = Colors.grey.shade100;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TimeTogetherScreen(roomCode: widget.roomCode)),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor:  Color(0xFF0B0B45),
        appBar: AppBar(
          title: Text("Active Polls", style: TextStyle(color: Colors.white)),
          backgroundColor: primaryColor,
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 3,
          centerTitle: true,
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('rooms')
              .doc(widget.roomCode)
              .collection('polls')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primaryColor));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("No active polls", style: TextStyle(fontSize: 16, color: Colors.grey[600])));
            }

            final polls = snapshot.data!.docs;

            return ListView(
              children: polls.map((poll) {
                final pollData = poll.data() as Map<String, dynamic>;
                final options = Map<String, dynamic>.from(pollData['options'] ?? {});
                final votedUsers = Map<String, dynamic>.from(pollData['votedUsers'] ?? {});
                final totalVotes = options.values.fold(0, (sum, value) => sum + (value as int));
                final hasVoted = votedUsers.containsKey(userId);

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pollData['question'] ?? "Untitled Poll",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primaryColor),
                        ),
                        SizedBox(height: 12),
                        Column(
                          children: options.entries.map((entry) {
                            final percentage = totalVotes > 0
                                ? (entry.value / totalVotes) * 100
                                : 0.0;
                            final isSelected = votedUsers[userId] == entry.key;

                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(entry.key, style: TextStyle(fontWeight: FontWeight.w500)),
                                subtitle: LinearProgressIndicator(
                                  value: percentage / 100,
                                  color: primaryColor,
                                  backgroundColor: Colors.grey[300],
                                ),
                                trailing: Text("${entry.value} votes", style: TextStyle(fontSize: 12)),
                                onTap: hasVoted ? null : () => vote(poll.id, entry.key),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            if (hasVoted)
                              Expanded(
                                child: Text(
                                  "You have already voted.",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ),
                            IconButton(
                              icon: Icon(Icons.delete_forever_rounded, color: Colors.black),
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
