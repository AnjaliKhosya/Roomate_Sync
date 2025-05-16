import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roomate_sync/services/PushNotificationService.dart';
class DetailExpensePage extends StatefulWidget {
  final String roomCode;
  final String expenseId;

  const DetailExpensePage({
    super.key,
    required this.roomCode,
    required this.expenseId,
  });

  @override
  State<DetailExpensePage> createState() => _DetailExpensePageState();
}

class _DetailExpensePageState extends State<DetailExpensePage> {
  Map<String, String> userNames = {};
  Map<String, String> userProfilePics = {};
  bool isLoading = true;
  double totalAmount = 0.0;
  String paidBy = '';
  List<Map<String, dynamic>> owedBy = []; // Each owedBy contains {id, isPaid}

  @override
  void initState() {
    super.initState();
    _fetchExpenseAndRoommateDetails();
  }

  Future<void> _fetchExpenseAndRoommateDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomCode)
          .collection('expenses')
          .doc(widget.expenseId)
          .get();

      if (!doc.exists) {
        setState(() => isLoading = false);
        return;
      }

      final data = doc.data()!;
      paidBy = data['paidBy'] ?? '';
      totalAmount = (data['amount'] ?? 0).toDouble();

      // owedBy is a list of maps: [{id: "userId", isPaid: true/false}, ...]
      final owedByData = List<Map<String, dynamic>>.from(data['owedBy'] ?? []);

      owedBy = owedByData;

      // Collect all user ids (owedBy + paidBy)
      final allUserIds = owedBy.map((e) => e['id'].toString()).toSet();
      allUserIds.add(paidBy);

      Map<String, String> tempNames = {};
      Map<String, String> tempPics = {};

      await Future.wait(allUserIds.map((userId) async {
        final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
        final userData = userDoc.data() ?? {};
        tempNames[userId] = userData['name'] ?? 'Unknown';
        tempPics[userId] = userData['profileImage'] ?? '';
      }));

      setState(() {
        userNames = tempNames;
        userProfilePics = tempPics;
        isLoading = false;
      });
    } catch (e) {
      print('🔥 Error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _togglePaid(String userId) async {
    setState(() {
      final index = owedBy.indexWhere((element) => element['id'] == userId);
      if (index != -1) {
        owedBy[index]['isPaid'] = !(owedBy[index]['isPaid'] ?? false);
      }
    });

    // Prepare updated owedBy list for Firestore
    final updatedOwedBy = owedBy.map((e) {
      return {'id': e['id'], 'isPaid': e['isPaid']};
    }).toList();

    // Update Firestore with new owedBy status
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomCode)
        .collection('expenses')
        .doc(widget.expenseId)
        .update({'owedBy': updatedOwedBy});

    // Check if all roommates have paid
    bool allPaid = owedBy.every((element) => element['isPaid'] == true);

    if (allPaid) {
      // Fetch the expense document to get paidByUserId
      final expenseDoc = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomCode)
          .collection('expenses')
          .doc(widget.expenseId)
          .get();

      if (expenseDoc.exists) {
        final paidByUserId = expenseDoc.data()?['paidBy'];

        if (paidByUserId != null) {
          // Fetch device token of paidByUserId from 'Roomates' collection
          final paidByDoc = await FirebaseFirestore.instance
              .collection('rooms')
              .doc(widget.roomCode)
              .collection('Roomates')
              .doc(paidByUserId)
              .get();

          if (paidByDoc.exists) {
            final deviceToken = paidByDoc.data()?['FCMToken'];

            if (deviceToken != null) {
              // Call your notification function
              await PushNotificationService.sendNotificationToSelectedRoommate(
                  deviceToken,
                  paidByUserId,
                  "💰 Payment Complete",
                  "All payments are settled. Feel free to remove this expense. 👍"
              );
            }
          }
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Expense Details', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹ ${totalAmount}',
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Payer: ${userNames[paidBy] ?? 'Unknown'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1.5),
            Expanded(
              child: ListView.builder(
                itemCount: owedBy.length,
                itemBuilder: (context, index) {
                  final user = owedBy[index];
                  final userId = user['id'];
                  final isPaid = user['isPaid'] ?? false;
                  final userName = userNames[userId] ?? 'Unknown';
                  final profilePic = userProfilePics[userId] ?? '';

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                        profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
                        backgroundColor: Colors.purple,
                        child: profilePic.isEmpty
                            ? Text(userName[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white))
                            : null,
                      ),
                      title: Text(userName),
                      trailing: Checkbox(
                        value: isPaid,
                        activeColor: Colors.green,
                        onChanged: (_) => _togglePaid(userId),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
