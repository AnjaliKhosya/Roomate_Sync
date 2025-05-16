import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class NewExpenseScreen extends StatefulWidget {
  final String roomCode;
  const NewExpenseScreen({super.key, required this.roomCode});

  @override
  State<NewExpenseScreen> createState() => _NewExpenseScreenState();
}

class _NewExpenseScreenState extends State<NewExpenseScreen> {
  final formKey = GlobalKey<FormState>();
  var fields = ['Expense Title', 'Date', 'Amount', 'Paid by', 'Owed by'];

  bool isLoading = false;
  List<Map<String, String>> roommates = [];
  String? selectedPaidPersonId;
  List<String> selectedOwedRoommateIds = [];
  List<TextEditingController> _controller = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < fields.length; i++) {
      _controller.add(TextEditingController());
    }
    fetchRoommates();
  }

  Future<void> fetchRoommates() async {
    setState(() => isLoading = true);

    try {
      var roommatesSnapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomCode)
          .collection('Roomates')
          .get();

      roommates = roommatesSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'] as String,
        };
      }).toList();

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading roommates: $e")),
      );
    }
  }

  Future<void> addExpense() async {
    if (formKey.currentState!.validate()) {
      try {
        final firestore = FirebaseFirestore.instance;

        // Create list of owed roommates with isPaid = false and lastReminderSent = null
        List<Map<String, dynamic>> owedByList = selectedOwedRoommateIds
            .map((id) => {
          'id': id,
          'isPaid': false,
          'lastReminderSent': null, // Initialize with null, no reminder sent yet
        })
            .toList();

        await firestore
            .collection('rooms')
            .doc(widget.roomCode)
            .collection('expenses')
            .add({
          'expenseTitle': _controller[0].text.trim(),
          'date': _controller[1].text.trim(),
          'amount': double.parse(_controller[2].text.trim()),
          'paidBy': selectedPaidPersonId,
          'owedBy': owedByList,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Expense added successfully!",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        for (var controller in _controller) {
          controller.clear();
        }
        setState(() {
          selectedPaidPersonId = null;
          selectedOwedRoommateIds.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add expense: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: const Color(0xFF0B0B45),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 40),
                    child: IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 20.0, top: 50),
                    child: Text(
                      'Create New Expense',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Italicfont',
                        fontSize: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: 200,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0XfffD9D9D9),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Form(
                            key: formKey,
                            child: Column(
                              children: [
                                ...List.generate(fields.length, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 15.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fields[index],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 20,
                                            fontFamily: 'Italicfont',
                                            color: Color(0xFF0B0B45),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0XfffD9D9D6),
                                            borderRadius: BorderRadius.circular(15),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.grey,
                                                spreadRadius: 1.5,
                                                blurRadius: 5,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: index == 3
                                              ? DropdownButtonFormField<String>(
                                            value: selectedPaidPersonId,
                                            items: roommates
                                                .map((roommate) => DropdownMenuItem<String>(
                                              value: roommate['id'],
                                              child: Text(roommate['name']!),
                                            ))
                                                .toList(),
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                                borderSide: const BorderSide(color: Color(0xFF0B0B45), width: 2),
                                              ),
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedPaidPersonId = value;
                                              });
                                            },
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return "Select a payer";
                                              }
                                              return null;
                                            },
                                          )
                                              : index == 4
                                              ? MultiSelectDialogField<String>(
                                            items: roommates
                                                .map((roommate) => MultiSelectItem<String>(
                                              roommate['id']!,
                                              roommate['name']!,
                                            ))
                                                .toList(),
                                            title: const Text("Select Roommates"),
                                            selectedColor: Color(0xFF0B0B45),
                                            decoration: BoxDecoration(
                                              color: const Color(0XfffD9D9D6),
                                              borderRadius: BorderRadius.circular(15),
                                              border: Border.all(color: Colors.grey),
                                            ),
                                            buttonText: const Text(
                                              "Select Roommates",
                                              style: TextStyle(color: Colors.black),
                                            ),
                                            onConfirm: (values) {
                                              setState(() {
                                                selectedOwedRoommateIds = values;
                                              });
                                            },
                                            validator: (values) {
                                              if (values == null || values.isEmpty) {
                                                return "Select at least one roommate";
                                              }
                                              return null;
                                            },
                                          )
                                              : TextFormField(
                                            controller: _controller[index],
                                            keyboardType: index == 2
                                                ? TextInputType.number
                                                : TextInputType.text,
                                            readOnly: index == 1,
                                            onTap: () async {
                                              if (index == 1) {
                                                DateTime? pickedDate = await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime(2101),
                                                );
                                                if (pickedDate != null) {
                                                  String date = DateFormat('dd/MM/yyyy')
                                                      .format(pickedDate);
                                                  _controller[index].text = date;
                                                }
                                              }
                                            },
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                                borderSide: const BorderSide(color: Color(0xFF0B0B45), width: 2),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "Enter ${fields[index]}";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                ElevatedButton(
                                  onPressed: addExpense,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0B0B45),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: const Text(
                                    "Add +",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Italicfont',
                                      fontSize: 20,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
