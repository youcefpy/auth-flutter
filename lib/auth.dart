import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  FirebaseAuth? _firebaseauth;
  User? getcurrentuser;

  Auth() {
    _firebaseauth = FirebaseAuth.instance;
    getcurrentuser = _firebaseauth!.currentUser;
  }
  Stream<User?> get authStateChanges => _firebaseauth!.authStateChanges();
  Future<void> singInWithEmailAndPassword({
    required email,
    required password,
  }) async {
    await _firebaseauth!
        .signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> singOut() async {
    await _firebaseauth!.signOut();
  }

  Future<void> createUserWithEmailAndPassword({
    required email,
    required password,
  }) async {
    await _firebaseauth!
        .createUserWithEmailAndPassword(email: email, password: password);
  }
}
