import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyCod0sqm4t0qvnob8WVvGFctR5yoeeYQvc',
    appId: '1:921012344723:web:748a9e18df729346e9ba66',
    messagingSenderId: '921012344723',
    projectId: 'socialmedia-f8829',
    authDomain: 'socialmedia-f8829.firebaseapp.com',
    storageBucket: 'socialmedia-f8829.firebasestorage.app',
    measurementId: 'G-654PPN80BM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAnSvzfk5CqHVp7wc335uaTJJYUCqguWpU',
    appId: '1:921012344723:android:468ae8c6056c75eae9ba66',
    messagingSenderId: '921012344723',
    projectId: 'socialmedia-f8829',
    storageBucket: 'socialmedia-f8829.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCrcShgpJwesotQcMCApC5LIl2s1OQOojc',
    appId: '1:921012344723:ios:673af37624aa8ce3e9ba66',
    messagingSenderId: '921012344723',
    projectId: 'socialmedia-f8829',
    storageBucket: 'socialmedia-f8829.firebasestorage.app',
    androidClientId:
        '921012344723-ob0ufkksfd5auucac23vrr9r9mt6kkb7.apps.googleusercontent.com',
    iosClientId:
        '921012344723-04qprmrjbtothh6pgp3o17vgt2ibk4fn.apps.googleusercontent.com',
    iosBundleId: 'com.example.socialMedia',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCrcShgpJwesotQcMCApC5LIl2s1OQOojc',
    appId: '1:921012344723:ios:673af37624aa8ce3e9ba66',
    messagingSenderId: '921012344723',
    projectId: 'socialmedia-f8829',
    storageBucket: 'socialmedia-f8829.firebasestorage.app',
    androidClientId:
        '921012344723-ob0ufkksfd5auucac23vrr9r9mt6kkb7.apps.googleusercontent.com',
    iosClientId:
        '921012344723-04qprmrjbtothh6pgp3o17vgt2ibk4fn.apps.googleusercontent.com',
    iosBundleId: 'com.example.socialMedia',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCod0sqm4t0qvnob8WVvGFctR5yoeeYQvc',
    appId: '1:921012344723:web:064e090e397fcc84e9ba66',
    messagingSenderId: '921012344723',
    projectId: 'socialmedia-f8829',
    authDomain: 'socialmedia-f8829.firebaseapp.com',
    storageBucket: 'socialmedia-f8829.firebasestorage.app',
    measurementId: 'G-K29XFGRJ3Q',
  );
}
