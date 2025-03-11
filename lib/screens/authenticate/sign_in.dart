import 'package:brew_crew/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Import FirebaseAuth to use User
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthServices _auth = AuthServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: Text('Sign in to Brew Crew'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: ElevatedButton(
          onPressed: () async {
            User? result = await _auth.signInAnon();
            if (result == null) {
              print('Error signing in');
            } else {
              print('Signed in');
              print('User ID: ${result.uid}'); // Show only the user ID
            }
          },
          child: Text('Sign in Anon'),
        ),
      ),
    );
  }
}
