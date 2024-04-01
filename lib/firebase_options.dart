// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDLkYd5T-rBD_S_-0SGCrcfjr19pPBw2Gc',
    appId: '1:51951652454:web:f6ce57e91e4863750d27a7',
    messagingSenderId: '51951652454',
    projectId: 'crosscheck-f5521',
    authDomain: 'crosscheck-f5521.firebaseapp.com',
    databaseURL: 'https://crosscheck-f5521-default-rtdb.firebaseio.com',
    storageBucket: 'crosscheck-f5521.appspot.com',
    measurementId: 'G-XDLJTX72F7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAyp82CflvccWCEJuutNDubjCuGlXUd5ro',
    appId: '1:51951652454:android:730faed1b1033c800d27a7',
    messagingSenderId: '51951652454',
    projectId: 'crosscheck-f5521',
    databaseURL: 'https://crosscheck-f5521-default-rtdb.firebaseio.com',
    storageBucket: 'crosscheck-f5521.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD5GotVKOZYPKAan8TvnsVMA-VTE0pIHts',
    appId: '1:51951652454:ios:4532e1ce2fa2c8a50d27a7',
    messagingSenderId: '51951652454',
    projectId: 'crosscheck-f5521',
    databaseURL: 'https://crosscheck-f5521-default-rtdb.firebaseio.com',
    storageBucket: 'crosscheck-f5521.appspot.com',
    iosBundleId: 'com.example.empowereed2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD5GotVKOZYPKAan8TvnsVMA-VTE0pIHts',
    appId: '1:51951652454:ios:4d97c718806b915c0d27a7',
    messagingSenderId: '51951652454',
    projectId: 'crosscheck-f5521',
    databaseURL: 'https://crosscheck-f5521-default-rtdb.firebaseio.com',
    storageBucket: 'crosscheck-f5521.appspot.com',
    iosBundleId: 'com.example.empowereed2.RunnerTests',
  );
}