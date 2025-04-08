import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:roomate_sync/notification_services.dart';
import 'package:roomate_sync/PushNotificationService.dart';

class NewTaskScreen extends StatefulWidget{
  final String roomCode;
  NewTaskScreen({required this.roomCode});
  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final formKey = GlobalKey<FormState>();
  List<TextEditingController> controllers = [];
  var fieldNames = ['Title','Deadline','Assigned To'];
  String? selectedRoomateId = null;
  List<Map<String,dynamic>> roomatesList=[];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    for(int i =0;i<2;i++)
      controllers.add(TextEditingController());
    fetchRoomates();
  }

  fetchRoomates()async{
    setState(() {
      isLoading = true;
    });
    try {
      var roomates = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomCode)
          .collection('Roomates')
          .get();
      setState(() {
        roomatesList = roomates.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['name'],
          };
        }).toList();
        isLoading = false;
      });
      print("Roommates fetched: $roomatesList");
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading roommates: $e")));
    }
  }
  void addTask() async {
    if (formKey.currentState!.validate()) {
      try {
        if (selectedRoomateId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text("Please select a roommate!"),
            ),
          );
          return;
        }

        String tempSelectedRoommateId = selectedRoomateId!; // Store before clearing
        String taskTitle = controllers[0].text.trim();

        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.roomCode)
            .collection('tasks')
            .add({
          'title': taskTitle,
          'deadline': controllers[1].text.trim(),
          'assignedTo': tempSelectedRoommateId,
          'status': 'pending'
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Task added successfully!!",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );

        // Clear input fields
        for (var controller in controllers) {
          controller.clear();
        }
        selectedRoomateId = null;
        setState(() {});

        // Send notification in the background
        Future.microtask(() => sendNotificationToRoommate(tempSelectedRoommateId, widget.roomCode, taskTitle));

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add task: $e")),
        );
      }
    }
  }
  Future<void> sendNotificationToRoommate(String userId, String roomCode, String taskTitle,) async {
    try {
      final userRef = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomCode)
          .collection('Roomates')
          .doc(userId)
          .get();

      final userDoc = userRef.data();

      if (userDoc == null || !userDoc.containsKey('FCMToken')) {
        print('No FCM token found for user.');
        return;
      }

      final deviceToken = userDoc['FCMToken'];

      if (deviceToken != null && deviceToken.isNotEmpty) {
        await PushNotificationService.sendNotificationToSelectedRoommate(
            deviceToken,
            context,
            userId,
            'New Task Assigned',
            '📌 You have been assigned a task: $taskTitle',
        );
        print(' Notification sent to $userId');
      } else {
        print('User has no valid device token');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
  updateNoOfTasks(String userId) async {
    try{
      var userFieldRef = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomCode)
          .collection('Roomates')
          .doc(userId);
      await userFieldRef.update({
        'totalTasks': FieldValue.increment(1),
      });
      print('Count updated');
    }catch (e) {
      print('Error updating task count: $e');
    }
  }

  @override
  Widget build(BuildContext context)
  {
    String roomcode = widget.roomCode;
    return isLoading?
    Center(child: CircularProgressIndicator(),):
    Scaffold(
      resizeToAvoidBottomInset: true,
      body:SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Color(0Xfff284B63),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0,top: 40),
                    child: IconButton(onPressed: (){
                      ScaffoldMessenger.of(context).clearSnackBars();
                      Navigator.of(context).pop();
                    }, icon: Icon(Icons.menu,color: Colors.white,) ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 20.0,top: 50),
                    child: Text('Create New Task',style: TextStyle(color: Colors.white,fontFamily: 'Italicfont',fontSize: 25),),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 200,
              child: Container(
                decoration: BoxDecoration(
                    color: Color(0XfffD9D9D9),
                    borderRadius: BorderRadius.only(topRight: Radius.circular(30),topLeft: Radius.circular(30))
                ),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5, // Adjust the height as needed
                          child: Form(
                            key:formKey,
                            child: ListView.builder(
                              itemBuilder: (context, index) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10.0),
                                      child: Text(
                                        '${fieldNames[index]}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 20,
                                          fontFamily: 'Italicfont',
                                          color: Color(0Xfff353535),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 15.0),
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(0XfffD9D9D6),
                                            borderRadius: BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey,
                                                spreadRadius: 1.5,
                                                blurRadius: 5,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: index==2?
                                          DropdownButtonFormField<String>(
                                            value: selectedRoomateId,
                                            items: roomatesList.isEmpty
                                                ? [DropdownMenuItem(value: null, child: Text("No roommates available"))]
                                                : roomatesList.map((roomate) {
                                              return DropdownMenuItem<String>(
                                                value: roomate['id'],
                                                child: Text(roomate['name']),
                                              );
                                            }).toList(),
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedRoomateId = value;
                                              });
                                            },
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "Select a roommate";
                                              }
                                              return null;
                                            },
                                          )

                                              :TextFormField(
                                            readOnly: index == 1 ? true : false,
                                            onTap: () async {

                                              if (index == 1) {
                                                DateTime? pickedDate = await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime.now(),
                                                  lastDate: DateTime(2030),
                                                );
                                                if (pickedDate != null) {
                                                  String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
                                                  controllers[index].text = formattedDate;
                                                }

                                              }
                                            },
                                            controller: controllers[index],
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                            ),
                                            validator: (value){
                                              if(value!.isEmpty)
                                              {
                                                return "Enter ${fieldNames[index]}";
                                              }
                                              else
                                                return null;
                                            },

                                          )
                                      ),
                                    ),
                                  ],
                                );
                              },
                              itemCount: fieldNames.length,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 100.0, top: 20, bottom: 50),
                        child: Container(
                          height: 50,
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                              if (controllers.any((controller) => controller.text.isEmpty) ||selectedRoomateId == null)
                              {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Please fill all fields",style: TextStyle(fontSize: 15,fontFamily: 'Italicfont'),),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              else
                              {
                                addTask();
                                updateNoOfTasks(selectedRoomateId!);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 5, backgroundColor: Color(0Xfff284B63),
                              shadowColor: Colors.teal,
                            ),
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Italicfont',
                                fontSize: 25,
                                fontWeight: FontWeight.w300,
                              ),
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
