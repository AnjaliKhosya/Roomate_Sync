import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:roomate_sync/RoomCodeScreen.dart';

class GoogleAuthService {
  // ✅ Scopes already include Calendar
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar',
    ],
  );

  static Future<bool> signInWithGoogle(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Navigator.of(context).pop();
        return false;
      }

      // Auth tokens
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase sign-in
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Close loading & go to room code screen
      Navigator.of(context).pop();
      Get.offAll(() => roomcodeScreen());
      return true;
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In failed."), backgroundColor: Colors.red),
      );
      return false;
    }
  }

  static GoogleSignIn get googleSignIn => _googleSignIn;
}
