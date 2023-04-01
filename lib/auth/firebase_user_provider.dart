import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class GymAppFirebaseUser {
  GymAppFirebaseUser(this.user);
  User? user;
  bool get loggedIn => user != null;
}

GymAppFirebaseUser? currentUser;
bool get loggedIn => currentUser?.loggedIn ?? false;
Stream<GymAppFirebaseUser> gymAppFirebaseUserStream() => FirebaseAuth.instance
        .authStateChanges()
        .debounce((user) => user == null && !loggedIn
            ? TimerStream(true, const Duration(seconds: 1))
            : Stream.value(user))
        .map<GymAppFirebaseUser>(
      (user) {
        currentUser = GymAppFirebaseUser(user);
        return currentUser!;
      },
    );
