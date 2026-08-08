import 'dart:io';

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isAndroid) return android;
    if (Platform.isIOS) return ios;
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBggSg46AxGP7P5G2UvgUt1IoufUAYQpPQ',
    appId: '1:39014406908:android:b47ec9da0d45ffcf2e1579',
    messagingSenderId: '39014406908',
    projectId: 'nextgen-scholars',
    storageBucket: 'nextgen-scholars.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD1qG7lNH27ZSaVeuQ9W1SNWTlTmiQHN1c',
    appId: '1:39014406908:ios:edf7e5bc202c7e4b2e1579',
    messagingSenderId: '39014406908',
    projectId: 'nextgen-scholars',
    storageBucket: 'nextgen-scholars.firebasestorage.app',
    iosClientId:
        '39014406908-ugsq8i7qkh3hmj6kqni3kgomlrv38rrk.apps.googleusercontent.com',
    iosBundleId: 'com.example.scholarshipApp',
  );
}
