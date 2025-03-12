import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_delivery_app/repository/auth/firebase_auth_service.dart';
import 'package:grocery_delivery_app/router/app_router.dart';
import 'package:grocery_delivery_app/utils/widgets/authentication/phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants/custom_snackbar.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final FirebaseAuthService authService = FirebaseAuthService();
  bool validPhone = false;
  bool isLoading = false;
  String phoneNum = "";
  TextEditingController phoneController = TextEditingController();

  validatePhone(String phone) {
    if (phone.length != 9) {
      setState(() {
        validPhone = false;
      });
      return 'Enter a valid phone number (9 digits)';
    } else {
      setState(() {
        validPhone = true;
        phoneNum = "+254" + phone;
      });
    }
  }

  Future<void> _savePhone(String phone) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone', phone);
  }

  void initiateSignIn() {
    validatePhone(phoneController.text);
    if (validPhone) {
      _savePhone(phoneNum);
      setState(() {
        isLoading = true;
      });

      authService.signInWithPhone(
        phoneNum,
        context,
        (verificationId, resendToken) {
          setState(() {
            isLoading = false;
          });
          Navigator.pushNamed(context, AppRouter.otpscreen, arguments: verificationId);
        },
        (errorMessage) {
          setState(() {
            isLoading = false;
          });
          showCustomSnackbar(context, errorMessage);
        },
      );
    } else {
      showCustomSnackbar(context, 'Please enter a valid phone number (9 digits)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Phone Verification")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            PhoneField(controller: phoneController),
            SizedBox(height: 20),
            isLoading ? CircularProgressIndicator() : ElevatedButton(
              onPressed: initiateSignIn,
              child: Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
