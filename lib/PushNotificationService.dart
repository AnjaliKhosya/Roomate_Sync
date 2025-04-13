import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class PushNotificationService
{
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "roomatesync-83596",
      "private_key_id": "436676e3f53ee7f1acc3f8d9fb3486dc2bfc239a",
      "private_key": """
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDcKrEXHQawv8B8
94Ud8Kv1ZwmCRwSVLlPd/mkWvVrL/Ajj/PHg4svpF1AAmPWI/pDpj+fpeMfuWkr1
LS9vSjvZdWVTRrF/0zWclX2ArWFPayWJPKme4qCMS9Gi5JjKJtGBtWF8ZJ49QHAB
1ZdU0yAt3NokrmSH5LRwYCS2pFyNsO80uz9dq15EF73PCpzDt5ySPpeJySf1Knoc
CKcOLpM9kMYdXDuNn1RjqGj1bxLJlIj2mEjO+jvjO242I4tlADX7IU8gxguq0wha
gg9ZRfax5x7wdQiYqQm1O76xd+kYJ3ItuxzWiTas6wPjPB3zWTnzlIqxqoTp2NL5
v+tm6GZxAgMBAAECggEAEG9UEonKpuVcJ5f3L7x4Vv8kNmg5vy8a+JkrXBSyKJmo
Sj3mtRGzr13botJy5bvnB7WugKmmTF8gyvuJV8aUACV4yltzwuXP0eAA4zBOHCEU
nLwoB0xwjU3YQ3ogA7BxIZHEygXddWy6z7ro1d6qv3Gwi7Nu8ralAjcoa8U02X4R
HXZwRwR2E9Q4K/btQa/lM2fD/InQCBbvRjBmCw2GUdt8JC0yKCnDlp9sDgBCmrB6
yLHO7n7Z8e0L5qFl+R7snUzoXUUh9lkiRWi3ieX4klTbIT/iIqy4p8G9X5EBQnCv
HQj4jmP8MGG51HJWEaQKnL4Sfbw68zmj/6VzlfRSLwKBgQDwLwM5YIJDdgU30S0/
Hv4ix1kT96mHs3Xq0HuU403hdXnVnA2/exEcW9Eo5YMVsLOMWcvkvsEf5iaz/vMm
QqbZjLHmGaHiwtcPCP1jDUEqLuf1/tSi/rwD5xo9rgCn77qxX9bXGlF/9nkbInwU
rNeJkc7Nx0QwRfhSdGaUdG6JwwKBgQDqqjysJKFFsv6Gb3/uKQVFU4CCEENoBqm8
ICBzbm4poznDojZaO2S1i+0ffd+x1XvoJtGgN3IrAoPNxvapmubn/RToe3NJLSzO
wXDgzXhpYra7A3PT466Gbg+nMoY4i0SG8Y7S5hQMMsX5ACnlZYyRnYWfjUuviYQc
7LWOez3XuwKBgAi3/Cr6COCACUJ0cmsHKfyDNgWWiO3nItGqTcIi2jHj/M83QfyA
cCeSYa5VXoPMDUh7/f3IuuP4i9Ee4R6zbrEY/WA37/t2TS47ik8tLP9mAn+Yh4l/
K74MhpRUm6t89U75Bqh6SRkXDmBgyRZLC+vvgg1QPXZvI8uCdDLRYy3XAoGAPL0R
dTEJ+SNqU9uaTkeZ0KbbVU7mU4+d8U6Td602oFpaQjPDQ7mpyH/OQV9wPfRW3PDn
Q0P2rgE5olKEV8P7TkKoXcBOR7uEpINXNyiXqRde2qr7GPYOn0bvkEQ4j3wkoZT2
dcoNmFav/VI4heKx7qLKClElLOs4IdB28ckeaa8CgYEA79Av6pB790vE+mbvvWGW
SZLvp1Nx+UQ7sYV03vISlBBnSgqf9lluJmM1LRZqkQ4PPgMNIuKyEmSIIUqpW1Cu
XqFD0q/jJjcIjbnny+rPW7vx3QuYpNV32RCp1Jbw3XlNLnMj79Az103CPnF+eRFC
BJcZyGWZmt6A/yJCanoFNuI=
-----END PRIVATE KEY-----
""",   // ✅ Properly formatted multi-line string

      "client_email": "roomatesync-serviceaccount@roomatesync-83596.iam.gserviceaccount.com",
      "client_id": "102724147447044438892",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/roomatesync-serviceaccount%40roomatesync-83596.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    final httpClient = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      httpClient,
    );

    httpClient.close();
    return credentials.accessToken.data;
  }
  static Future<List<String>> fetchAllFcmTokens(String roomCode) async {
    List<String> tokens = [];

    final snapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomCode)
        .collection('Roomates')
        .get();

    for (var doc in snapshot.docs) {
      final token = doc.data()['FCMToken'];
      if (token != null && token.toString().isNotEmpty) {
        tokens.add(token.toString());
      }
    }

    return tokens;
  }
  static Future<void> sendNotificationToAllRoommates({
    required String roomCode,
    required String title,
    required String body,
  }) async {
    try {
      final List<String> deviceTokens = await fetchAllFcmTokens(roomCode);
      if (deviceTokens.isEmpty) {
        print("No FCM tokens found for room: $roomCode");
        return;
      }

      final String serverAccessToken = await getAccessToken();
      String endPoint = 'https://fcm.googleapis.com/v1/projects/roomatesync-83596/messages:send';

      for (String token in deviceTokens) {
        final message = {
          'message': {
            'token': token,
            'notification': {
              'title': title,
              'body': body,
            },
          }
        };

        final response = await http.post(
          Uri.parse(endPoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $serverAccessToken'
          },
          body: jsonEncode(message),
        );

        if (response.statusCode == 200) {
          print("Notification sent to $token successfully!");
        } else {
          print("Failed to send to $token: ${response.body}");
        }
      }
    } catch (e) {
      print("Error sending notifications: $e");
    }
  }


  static Future<void> sendNotificationToSelectedRoommate(
      String deviceToken,
      String userId,
      String title,
      String body
      ) async
  {

    final String serverAccessToken = await getAccessToken();
    String endPoint = 'https://fcm.googleapis.com/v1/projects/roomatesync-83596/messages:send';

    final message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': title,
          'body': body,
        },
        'data': {'userId': userId}
      }
    };

    final response = await http.post(
      Uri.parse(endPoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessToken'
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print("Notification sent successfully!");
    } else {
      print("Failed: ${response.body}");
    }
  }
}
