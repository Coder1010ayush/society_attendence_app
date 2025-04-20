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
    apiKey: 'AIzaSyDFsqb2oybXY79Yx2rWd6YNLlBjZMzes6g',
    appId: '1:833888073406:web:42869e9b970dbea56510ef',
    messagingSenderId: '833888073406',
    projectId: 'attendence-app-62faf',
    authDomain: 'attendence-app-62faf.firebaseapp.com',
    databaseURL: 'https://attendence-app-62faf-default-rtdb.firebaseio.com',
    storageBucket: 'attendence-app-62faf.firebasestorage.app',
    measurementId: 'G-RFL6H5Y1HX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBZHuWXwvv9y-6VqjbzfDgLfMepPkgk094',
    appId: '1:833888073406:android:bc405a5b133e046e6510ef',
    messagingSenderId: '833888073406',
    projectId: 'attendence-app-62faf',
    databaseURL: 'https://attendence-app-62faf-default-rtdb.firebaseio.com',
    storageBucket: 'attendence-app-62faf.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyChp0RRl2hoSY0gNn-cuHMh63A3dwvVftI',
    appId: '1:833888073406:ios:d7aaee2facf483ae6510ef',
    messagingSenderId: '833888073406',
    projectId: 'attendence-app-62faf',
    databaseURL: 'https://attendence-app-62faf-default-rtdb.firebaseio.com',
    storageBucket: 'attendence-app-62faf.firebasestorage.app',
    iosBundleId: 'com.example.attendenceApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDFsqb2oybXY79Yx2rWd6YNLlBjZMzes6g',
    appId: '1:833888073406:web:3bbbb5e99d9a76ac6510ef',
    messagingSenderId: '833888073406',
    projectId: 'attendence-app-62faf',
    authDomain: 'attendence-app-62faf.firebaseapp.com',
    databaseURL: 'https://attendence-app-62faf-default-rtdb.firebaseio.com',
    storageBucket: 'attendence-app-62faf.firebasestorage.app',
    measurementId: 'G-JNB6BD27S5',
  );
}
