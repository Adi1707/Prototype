import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyAb6cBWFjf0Z7w_9a7z0m1TSnwwDOnWn3M",
            authDomain: "abccddd.firebaseapp.com",
            projectId: "abccddd",
            storageBucket: "abccddd.appspot.com",
            messagingSenderId: "897614655432",
            appId: "1:897614655432:web:3fd02b362872d48a415afd",
            measurementId: "G-1CEWQZMKS0"));
  } else {
    await Firebase.initializeApp();
  }
}
