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
        return ios;
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
    apiKey: 'AIzaSyABoBdRh15tU3Wr0y1Mp8L3QYw6iJ-Z2sE',
    appId: '1:422896380842:web:ec6fc9f31e9138cd1b59d3',
    messagingSenderId: '422896380842',
    projectId: 'health-connect-bd597',
    authDomain: 'health-connect-bd597.firebaseapp.com',
    storageBucket: 'health-connect-bd597.appspot.com',
    measurementId: 'G-XK5L3ME73E',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB0hNTEWKn8OjoyxOB_aY_4lpzf-Evef44',
    appId: '1:422896380842:android:506a7117538fe0c41b59d3',
    messagingSenderId: '422896380842',
    projectId: 'health-connect-bd597',
    storageBucket: 'health-connect-bd597.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAuA2NdQwyHB3uOc6eWMnMItURG7DxGggU',
    appId: '1:422896380842:ios:c6d58c7eb1e5fa981b59d3',
    messagingSenderId: '422896380842',
    projectId: 'health-connect-bd597',
    storageBucket: 'health-connect-bd597.appspot.com',
    iosBundleId: 'com.example.healthConnectNew',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAuA2NdQwyHB3uOc6eWMnMItURG7DxGggU',
    appId: '1:422896380842:ios:c6d58c7eb1e5fa981b59d3',
    messagingSenderId: '422896380842',
    projectId: 'health-connect-bd597',
    storageBucket: 'health-connect-bd597.appspot.com',
    iosBundleId: 'com.example.healthConnectNew',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyABoBdRh15tU3Wr0y1Mp8L3QYw6iJ-Z2sE',
    appId: '1:422896380842:web:b5978ab349fceea71b59d3',
    messagingSenderId: '422896380842',
    projectId: 'health-connect-bd597',
    authDomain: 'health-connect-bd597.firebaseapp.com',
    storageBucket: 'health-connect-bd597.appspot.com',
    measurementId: 'G-1S5PQ42FXP',
  );
}
