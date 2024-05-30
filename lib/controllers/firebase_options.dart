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
    apiKey: 'AIzaSyBMH_J7kG74WlZkwkhiqbhMMh8G4_VXv78',
    appId: '1:42703193426:web:139cfbf197262f93e9668b',
    messagingSenderId: '42703193426',
    projectId: 'login-21cc2',
    authDomain: 'login-21cc2.firebaseapp.com',
    storageBucket: 'login-21cc2.appspot.com',
    measurementId: 'G-LW65HVHVN2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBm7whWO8ZQMmlYKJT5fX0EUqLdg6E9jyw',
    appId: '1:42703193426:android:2067fcf849340413e9668b',
    messagingSenderId: '42703193426',
    projectId: 'login-21cc2',
    storageBucket: 'login-21cc2.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD39HRH_bytxbtA-MGMBN7Iu5_-X_eo7fM',
    appId: '1:42703193426:ios:108210fd98d8d33ce9668b',
    messagingSenderId: '42703193426',
    projectId: 'login-21cc2',
    storageBucket: 'login-21cc2.appspot.com',
    iosBundleId: 'com.example.login',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD39HRH_bytxbtA-MGMBN7Iu5_-X_eo7fM',
    appId: '1:42703193426:ios:b995213c5f3a0a5fe9668b',
    messagingSenderId: '42703193426',
    projectId: 'login-21cc2',
    storageBucket: 'login-21cc2.appspot.com',
    iosBundleId: 'com.example.login.RunnerTests',
  );
}
