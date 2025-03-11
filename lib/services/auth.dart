import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user; // Use User? instead of FirebaseUser
      return user;
    } catch (e) {
      print("Error signing in anonymously: ${e.toString()}");
      return null;
    }
  }
}
