import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:roomate_sync/MainScreen.dart';
import 'RoomCodeScreen.dart';
import 'Varify.dart';
import 'loginScreen.dart';

class Wrapper extends StatefulWidget {
  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool isNavigating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("Firebase Error: ${snapshot.error}");
            return Center(child: Text("An error occurred. Please restart the app."));
          }

          if (!isNavigating) {
            isNavigating = true; // Prevents multiple navigations
            Future.microtask(() async {
              if (snapshot.hasData) {
                User? user = snapshot.data;

                if (user != null && user.emailVerified) {
                  /// 🔥 Check if the user already belongs to a room
                  var userDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get();

                  if (userDoc.exists && userDoc.data()?['roomCode'] != null) {
                    /// 🔥 Navigate directly to the user's room
                    String roomCode = userDoc['roomCode'];
                    Get.offAll(() => MainScreen(roomCode: roomCode));
                  } else {
                    /// 🔥 Navigate to the Room Code Screen if no room is found
                    Get.offAll(() => roomcodeScreen());
                  }
                } else {
                  /// 🔥 Redirect to Email Verification Screen
                  Get.offAll(() => Varify());
                }
              } else {
                /// 🔥 Redirect to Login Screen if no user is logged in
                Get.offAll(() => loginScreen());
              }
            });
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
