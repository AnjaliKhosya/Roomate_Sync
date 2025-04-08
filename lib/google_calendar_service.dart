import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:roomate_sync/google_auth_service.dart';

class GoogleCalendarService {
  static Future<void> createAllDayEvent({
    required String title,
    required String description,
    required DateTime date,
  }) async {
    final googleUser = await GoogleAuthService.googleSignIn.currentUser ??
        await GoogleAuthService.googleSignIn.signIn();

    if (googleUser == null) {
      print("❌ Google user not signed in.");
      return;
    }

    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;

    if (accessToken == null) {
      print("❌ Access token not found.");
      return;
    }

    final response = await http.post(
      Uri.parse('https://www.googleapis.com/calendar/v3/calendars/primary/events'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'summary': title,
        'description': description,
        'start': {
          'date': date.toIso8601String().split('T')[0],
        },
        'end': {
          'date': date.add(Duration(days: 1)).toIso8601String().split('T')[0],
        },
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ Event added to calendar.");
    } else {
      print("❌ Failed to add event: ${response.body}");
    }
  }
}
