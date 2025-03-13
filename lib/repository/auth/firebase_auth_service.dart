// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';


// class FirebaseAuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Get the current user
//   User? getCurrentUser() {
//     return _auth.currentUser;
//   }

//   // Sign in with email and password
//   Future<User?> signInWithEmailPassword(String email, String password) async {
//     try {
//       UserCredential result = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return result.user;
//     } catch (e) {
//       print('Error signing in: $e');
//       rethrow;
//     }
//   }

//   // Register with email and password
//   Future<User?> registerWithEmailPassword(String email, String password) async {
//     try {
//       UserCredential result = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return result.user;
//     } catch (e) {
//       print('Error registering user: $e');
//       rethrow;
//     }
//   }

//   void signInWithPhone(
//     String phoneNumber,
//     BuildContext context,
//     Function(String, int?) codeSent,
//     Function(String) onError,
//   ) async {
//     try {
//       await _auth.verifyPhoneNumber(
//         phoneNumber: phoneNumber,
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           await _auth.signInWithCredential(credential);
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           onError(e.message ?? "Verification failed");
//         },
//         codeSent: codeSent,
//         codeAutoRetrievalTimeout: (String verificationId) {},
//         timeout: const Duration(seconds: 60),
//       );
//     } catch (e) {
//       onError("Error: $e");
//     }
//   }

//   // Sign out
//   Future<void> signOut() async {
//     try {
//       return await _auth.signOut();
//     } catch (e) {
//       print('Error signing out: $e');
//       rethrow;
//     }
//   }
// }



import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign in with email and password
  Future<(User?, String?)> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return (result.user, null);
    } catch (e) {
      print('Error signing in: $e');
      return (null, e.toString());
    }
  }

  // Register with email and password
  Future<(User?, String?)> registerWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return (result.user, null);
    } catch (e) {
      print('Error registering user: $e');
      return (null, e.toString());
    }
  }

  // Sign in with phone
  Future<void> signInWithPhone(
    String phoneNumber,
    BuildContext context,
    Function(String, int?) codeSent,
    Function(String) onError,
  ) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-sign in with the received OTP
          try {
            await _auth.signInWithCredential(credential);
            Navigator.pushNamed(context, "/home"); // Auto-navigate if OTP is auto-retrieved
          } catch (e) {
            onError("Authentication failed: ${e.toString()}");
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Verification Failed: ${e.message}");
          onError(e.message ?? "Verification failed. Try again.");
        },
        codeSent: codeSent,
        codeAutoRetrievalTimeout: (String verificationId) {
          print("Code auto-retrieval timeout for $phoneNumber");
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      print("Phone authentication error: $e");
      onError("Error: $e");
    }
  }

  // Resend OTP
  Future<void> resendOTP(
    String phoneNumber,
    BuildContext context,
    Function(String, int?) codeSent,
    Function(String) onError,
  ) async {
    signInWithPhone(phoneNumber, context, codeSent, onError);
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
}