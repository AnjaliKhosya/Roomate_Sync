import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'MainScreen.dart';
import 'package:roomate_sync/notification_services.dart';

class roomcodeScreen extends StatefulWidget{
  @override
  State<roomcodeScreen> createState() => _roomcodeScreenState();
}

class _roomcodeScreenState extends State<roomcodeScreen>
{
  final formKey = GlobalKey<FormState>();
  var roomcode = TextEditingController();
  var validationMsg = "";
  joinRoom() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        validationMsg = "";
      });

      try {
        String enteredRoomCode = roomcode.text.toUpperCase().trim();

        // Using collectionGroup to fetch any document that has the same roomCode
        var querySnapshot = await FirebaseFirestore.instance
            .collectionGroup('Roomates')
            .get();

        bool roomExists = false;
        for (var doc in querySnapshot.docs) {
          if (doc.reference.parent.parent!.id == enteredRoomCode) {
            roomExists = true;
            break;
          }
        }

        if (roomExists) {
          print("Room exists");
          await addInFireStore(enteredRoomCode);
          Get.offAll(() => MainScreen(roomCode: enteredRoomCode));
        } else {
          setState(() {
            validationMsg = 'Invalid code.';
          });
        }
      } catch (e) {
        setState(() {
          validationMsg = 'Something went wrong. Please try again later.';
        });
      }
    }
  }
  String generateRoomCode() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();

    String randomString = "";
    for(int i=0;i<6;i++)
    {
      int ind = random.nextInt(characters.length);
      randomString+=characters[ind];
    }
    return randomString;
  }
  createRoom()async{
    String newRoomcode = "";
    bool codeExist = true;
    while(codeExist)
    {
      newRoomcode = generateRoomCode().trim().toUpperCase();
      var roomSnapshot = await FirebaseFirestore.instance.collection('rooms').doc(newRoomcode).get();

      if(!roomSnapshot.exists)
      {
        codeExist = false;
        showDialog(context: context, builder: (context){
          return Container(
            child: AlertDialog(
              title: Center(child: Text(newRoomcode)),
              content: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0Xfff284B63),
                ),
                onPressed: ()async{
                  await addInFireStore(newRoomcode);
                  Get.offAll(()=>MainScreen(roomCode: newRoomcode,));
                },
                child: Text('Create Room',style: TextStyle(color: Colors.white,fontSize: 20,fontFamily: 'Italicfont'),),
              ),
            ),
          );
        });
      }

    }
  }
  Future<void> addInFireStore(String newRoomcode) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String userName = FirebaseAuth.instance.currentUser!.displayName ?? "Unknown User";

    NotificationServices notificationServices = NotificationServices();
    String token = await notificationServices.getDeviceToken();

    /// Add user to the Roomates collection in the room
    var userDoc = FirebaseFirestore.instance
        .collection('rooms')
        .doc(newRoomcode)
        .collection('Roomates')
        .doc(userId);

    await userDoc.set({
      'name': userName,
      'taskCompleted': 0,
      'totalTasks': 0,
      'FCMToken': token,
    });

    /// Store the room code in the users collection
    var userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId);

    await userRef.set({
      'roomCode': newRoomcode,
    }, SetOptions(merge: true));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Create a Room Code',style: TextStyle(color: Colors.white,fontFamily: 'Italicfont'))),
        backgroundColor:  Color(0Xfff284B63),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width:  MediaQuery.of(context).size.width,
          color: Color(0XffD9D9D9),
          child: Padding(
            padding: const EdgeInsets.only(left: 20,right: 20),
            child: Column(

              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0,bottom: 20,right: 20),
                  child: Container(
                    child: Image.asset('assets/images/Screenshot 2024-11-02 154832-removebg-preview.jpg',height: 250,width: 240,),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 5.0,right: 5,bottom: 5),
                    child: Form(
                      key: formKey,
                      child: TextFormField(
                        onTap: (){
                          setState(() {
                            validationMsg = "";
                          });
                        },
                        controller: roomcode,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.meeting_room_outlined),
                          hintText: 'Existing room code',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                            fontFamily: 'Italicfont',
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color(0Xff353535),
                              )
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color(0Xff14123D),
                                width: 1,
                              )
                          ),
                        ),
                        validator: (value){
                          if(value!.isEmpty)
                          {
                            return "Enter room code";
                          }
                          else
                            return null;
                        },
                      ),)
                ),//enter existing room code
                Padding(
                  padding: const EdgeInsets.only(right: 230),
                  child: Text(validationMsg,style: TextStyle(color: Colors.red,fontSize: 13,fontFamily: 'Italicfont'),),
                ),//validation message
                ElevatedButton(onPressed: (){
                  joinRoom();
                },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0Xfff284B63)
                    ),
                    child: Text('Join Room',style: TextStyle(fontSize: 20,fontFamily: 'Italicfont',color: Colors.white),)),//join room
                Padding(
                  padding: const EdgeInsets.only(top: 30.0,bottom: 30,left: 5,right: 5),
                  child: Row(
                    children:[
                      Expanded(
                        child: Divider(
                          thickness: 1, // Thickness of the line
                          color: Colors.grey, // Line color
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Or",
                          style: TextStyle(fontSize: 18,fontFamily: 'Italicfont'),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),//divider
                ElevatedButton(onPressed: (){
                  createRoom();
                },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0Xfff284B63)
                    ),
                    child: Text('New Room Code',style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w300,fontFamily: 'Italicfont',fontSize: 20
                    ),)),

              ],
            ),
          ),
        ),
      ),
    );
  }

}