import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlanActivityScreen extends StatefulWidget {
  final String roomCode;

  const PlanActivityScreen({Key? key, required this.roomCode}) : super(key: key);

  @override
  _PlanActivityScreenState createState() => _PlanActivityScreenState();
}

class _PlanActivityScreenState extends State<PlanActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customTitleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedActivity;

  final List<String> activityOptions = [
    'Movie Night',
    'Dinner & Cooking',
    'Gossip Time',
    'Game Night',
    'Outing',
    'Issue Sharing',
    'Shopping Together',
    'Makeover Night',
    'Dance & Music Night',
    'Other',
  ];

  bool get isCustom => selectedActivity == 'Other';

  @override
  void dispose() {
    _customTitleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Activity'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Select Activity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text("Choose an activity"),
                value: selectedActivity,
                items: activityOptions.map((String activity) {
                  return DropdownMenuItem<String>(
                    value: activity,
                    child: Text(activity),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedActivity = value;
                  });
                },
                validator: (value) => value == null ? 'Please select an activity' : null,
              ),
              if (isCustom) ...[
                const SizedBox(height: 20),
                const Text("Enter Custom Title", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _customTitleController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your activity name',
                  ),
                  validator: (value) {
                    if (isCustom && (value == null || value.trim().isEmpty)) {
                      return 'Please enter custom activity title';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 20),
              const Text("Select Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Choose a date',
                ),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                      _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
                validator: (value) => value == null || value.isEmpty ? 'Please select a date' : null,
              ),
              const SizedBox(height: 20),
              const Text("Select Time", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Choose a time',
                ),
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: selectedTime ?? TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      selectedTime = pickedTime;
                      _timeController.text = pickedTime.format(context);
                    });
                  }
                },
                validator: (value) => value == null || value.isEmpty ? 'Please select a time' : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() != true) return;

                    final activity = isCustom
                        ? _customTitleController.text.trim()
                        : selectedActivity ?? '';
                    final date = _dateController.text.trim();
                    final time = _timeController.text.trim();

                    if (activity.isEmpty || date.isEmpty || time.isEmpty || selectedTime == null || selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                    } else {
                      final dtParts = date.split('-');
                      final eventDateTime = DateTime(
                        int.parse(dtParts[0]),
                        int.parse(dtParts[1]),
                        int.parse(dtParts[2]),
                        selectedTime!.hour,
                        selectedTime!.minute,
                      );

                      try {
                        final activityRef = FirebaseFirestore.instance
                            .collection('rooms')
                            .doc(widget.roomCode)
                            .collection('activities')
                            .doc(); // Auto ID

                        await activityRef.set({
                          'title': activity,
                          'timestamp': eventDateTime.toUtc(),
                          'notified': false,
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Activity "$activity" planned successfully')),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to plan activity')),
                          );
                        }
                      }
                    }
                  },
                  child: const Text("Plan Activity"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
