import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../repository/auth/firebase_auth_service.dart';
import '../../router/app_router.dart';
import '../../utils/constants/custom_snackbar.dart';
import '../../utils/widgets/authentication/custom_textfield.dart';

class EnterKYCPage extends StatefulWidget {
  const EnterKYCPage({super.key});

  @override
  State<EnterKYCPage> createState() => _EnterKYCPageState();
}

class _EnterKYCPageState extends State<EnterKYCPage> {
  final FirebaseAuthService authService = FirebaseAuthService();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();
  bool isLoading = false;

  Future<String?> getPhoneNumber() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('phone');
  }

  void registerUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = await authService.registerWithEmailPassword(
        emailController.text,
        passwordController.text,
      );

      if (user != null) {
        await user.sendEmailVerification();
        String? phoneNumber = await getPhoneNumber();

        FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'firstname': firstnameController.text,
          'lastname': lastnameController.text,
          'email': emailController.text,
          "phoneNumber": phoneNumber,
          "verified": false,
        });

        showCustomSnackbar(context, "Registration successful. Please check your email.");
        Navigator.pushNamed(context, AppRouter.login);
      }
    } catch (error) {
      showCustomSnackbar(context, "Registration failed: $error");
    } finally {
      setState(() {
        isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(controller: firstnameController, hint: "First Name"),
            CustomTextField(controller: lastnameController, hint: "Last Name"),
            CustomTextField(controller: emailController, hint: "Email", keyboardType: TextInputType.emailAddress),
            CustomTextField(controller: passwordController, hint: "Password", isPassword: true),
            ElevatedButton(onPressed: registerUser, child: Text("Sign Up")),
          ],
        ),
      ),
    );
  }
}
