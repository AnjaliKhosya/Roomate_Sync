// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBAp3THNlDRY2KF80-Wf7FtmXCtToPOWnA',
    appId: '1:896045844969:web:4378fda443390551aee378',
    messagingSenderId: '896045844969',
    projectId: 'roomatesync-83596',
    authDomain: 'roomatesync-83596.firebaseapp.com',
    storageBucket: 'roomatesync-83596.firebasestorage.app',
    measurementId: 'G-96Q04HKKWG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAVzahjZ8XlQ-Ncwe8mH4F_-GJshDca-aY',
    appId: '1:896045844969:android:5c4ff1fc9799e47eaee378',
    messagingSenderId: '896045844969',
    projectId: 'roomatesync-83596',
    storageBucket: 'roomatesync-83596.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAFjNraJyoDphwHPNE4e7WxkCarzEKz_sU',
    appId: '1:896045844969:ios:e68043ebf13acb24aee378',
    messagingSenderId: '896045844969',
    projectId: 'roomatesync-83596',
    storageBucket: 'roomatesync-83596.firebasestorage.app',
    iosBundleId: 'com.example.roomateSync',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBAp3THNlDRY2KF80-Wf7FtmXCtToPOWnA',
    appId: '1:896045844969:web:95b8703b96466738aee378',
    messagingSenderId: '896045844969',
    projectId: 'roomatesync-83596',
    authDomain: 'roomatesync-83596.firebaseapp.com',
    storageBucket: 'roomatesync-83596.firebasestorage.app',
    measurementId: 'G-7GPH2E9QNV',
  );

}