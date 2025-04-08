import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';  // For UPI redirection

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
  Map<String, String> userNames = {};   // Stores <userID, name>
  Map<String, String> userUpiIds = {};  // Stores <userID, upiId>
  bool isLoading = true;                // Flag to track data loading

  @override
  void initState() {
    super.initState();
    _fetchRoommateDetails();
  }

  // ✅ Fetch Roommates' Names and UPI IDs
  Future<void> _fetchRoommateDetails() async {
    try {
      final expenseDoc = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomCode)
          .collection('expenses')
          .doc(widget.expenseId)
          .get();

      if (!expenseDoc.exists) {
        setState(() => isLoading = false);
        return;
      }

      List<dynamic> owedBy = expenseDoc['owedBy'] ?? [];
      String paidById = expenseDoc['paidBy'] ?? '';

      Map<String, String> tempNames = {};
      Map<String, String> tempUpiIds = {};

      // 🔥 Fetch roommate details concurrently
      List<Future<void>> fetchTasks = [];

      for (String userId in owedBy + [paidById]) {
        fetchTasks.add(FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get()
            .then((userDoc) {
          if (userDoc.exists) {
            final userData = userDoc.data()!;
            tempNames[userId] = userData['displayName'] ?? 'Unknown';
            tempUpiIds[userId] = userData['upiId'] ?? '';
          } else {
            tempNames[userId] = 'Unknown';
            tempUpiIds[userId] = '';
          }
        }));
      }

      await Future.wait(fetchTasks);

      setState(() {
        userNames = tempNames;
        userUpiIds = tempUpiIds;
        isLoading = false;
      });
    } catch (e) {
      print('🔥 Error fetching roommate details: $e');
      setState(() => isLoading = false);
    }
  }

  // ✅ UPI Payment Method (Handles both double and string amounts)
  Future<void> _payWithUPI(String upiId, dynamic amount, String note) async {
    String amountStr = amount.toString();  // 🔥 Ensure amount is a String
    String upiUrl = "phonepe://pay?pa=$upiId&pn=RoommateSync&am=$amount&tn=$note&cu=INR";

    Uri uri = Uri.parse(upiUrl);

    try {
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw 'Could not launch UPI app';
      }
    } catch (e) {
      print('🔥 Error launching UPI: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No UPI app found. Please install one.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Expense Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.roomCode)
            .collection('expenses')
            .doc(widget.expenseId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Expense not found'),
            );
          }

          final expenseData = snapshot.data!.data() as Map<String, dynamic>;
          final expenseTitle = expenseData['expenseTitle'] ?? 'No Title';
          final dynamic amount = expenseData['amount'] ?? '0';  // ✅ Use dynamic type
          final paidBy = expenseData['paidBy'] ?? 'Unknown';
          final owedBy = List<String>.from(expenseData['owedBy'] ?? []);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 🔥 Expense Summary
                Container(
                  height: 120,
                  width: 330,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹ ${amount.toString()}',  // ✅ Displaying the amount as String
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Paid by: ${userNames[paidBy] ?? 'Unknown'}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.grey, thickness: 1.5),
                const SizedBox(height: 10),

                // 🔥 Displaying Owed Roommates
                Expanded(
                  child: ListView.builder(
                    itemCount: owedBy.length,
                    itemBuilder: (context, index) {
                      final userId = owedBy[index];
                      final userName = userNames[userId] ?? 'Unknown';
                      final upiId = userUpiIds[userId] ?? '';

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(userName[0].toUpperCase()),
                          ),
                          title: Text(userName),
                          trailing: ElevatedButton.icon(
                            icon: const Icon(Icons.currency_rupee),
                            label: const Text("Pay Now"),
                            onPressed: upiId.isNotEmpty
                                ? () => _payWithUPI(upiId, amount, expenseTitle)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
