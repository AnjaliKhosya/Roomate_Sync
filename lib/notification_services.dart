import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// ✅ Request Notification Permissions
  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission');
    } else {
      print('❌ User denied the permission');
    }
  }

  /// ✅ Initialize Local Notifications
  void initLocalNotification(BuildContext context) async {
    var androidInitialization = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: androidInitialization);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) {
        print("User clicked on notification: ${payload.payload}");
      },
    );
  }

  /// ✅ Initialize Firebase Messaging and Listen for Notifications
  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      print("📩 Received message: ${message.notification?.title}");
      initLocalNotification(context);
      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('✅ App opened from background: ${message.messageId}');
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // ✅ Refresh token logic
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print('🔁 Refreshed FCM Token: $newToken');

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        String? roomCode = userDoc['roomCode'];
        if (roomCode != null) {
          await FirebaseFirestore.instance
              .collection('rooms')
              .doc(roomCode)
              .collection('users')
              .doc(user.uid)
              .update({'fcmToken': newToken});
        }
      }
    });
  }

  /// ✅ Background message handler function
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
  }

  /// ✅ Generate Device Token
  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    print('FCM Token: $token');
    return token!;
  }

  /// ✅ Show Notification Locally
  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(1000000).toString(),
      'Task Notifications',
      importance: Importance.max,
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: 'Notifications for assigned tasks',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No Body',
      notificationDetails,
    );
  }
}
