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
    'Digital Detox Day',
    'Other',
  ];

  bool get isCustom => selectedActivity == 'Other';

  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      suffixIcon: icon != null ? Icon(icon, color: const Color(0xFF0B0B45)) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

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
        backgroundColor: const Color(0xFF0B0B45),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Select Activity",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0B0B45),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("Choose an activity"),
                value: selectedActivity,
                style: const TextStyle(fontSize: 16, color: Color(0xFF0B0B45)),
                iconEnabledColor: const Color(0xFF0B0B45),
                dropdownColor: Colors.white,
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
                const Text(
                  "Enter Custom Title",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B0B45),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _customTitleController,
                  decoration: _inputDecoration('Enter your activity name'),
                  validator: (value) {
                    if (isCustom && (value == null || value.trim().isEmpty)) {
                      return 'Please enter custom activity title';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 20),
              const Text(
                "Select Date",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0B0B45),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: _inputDecoration('Choose a date', icon: Icons.calendar_today),
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
              const Text(
                "Select Time",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0B0B45),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                decoration: _inputDecoration('Choose a time', icon: Icons.access_time),
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

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero, // remove default padding
                    maximumSize: const Size(70, 50), // exact width and height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
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
                            .doc();

                        await activityRef.set({
                          'title': activity,
                          'timestamp': eventDateTime.toUtc(),
                          'notified': false,
                        });

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Activity "$activity" planned successfully')),
                          );

                          // Reset all fields
                          setState(() {
                            selectedActivity = null;
                            _customTitleController.clear();
                            _dateController.clear();
                            _timeController.clear();
                            selectedDate = null;
                            selectedTime = null;
                          });
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

                  child: const Text("Plan Activity",style: TextStyle(fontSize: 17),),
                ),

            ],
          ),
        ),
      ),
    );
  }
}
