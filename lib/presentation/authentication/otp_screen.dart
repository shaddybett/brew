import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_delivery_app/router/app_router.dart';
import 'package:grocery_delivery_app/utils/widgets/authentication/otp_field.dart';
import '../../utils/constants/custom_snackbar.dart';

class OtpScreen extends StatefulWidget {
  final String verificationCode;
  const OtpScreen({super.key, required this.verificationCode});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  void verifyOtp(String otp) async {
    setState(() {
      isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationCode,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      Navigator.pushNamed(context, AppRouter.kycpage);
    } catch (e) {
      showCustomSnackbar(context, "Invalid OTP. Please try again.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            OTPField(onOtpEntered: verifyOtp),
            SizedBox(height: 20),
            isLoading ? CircularProgressIndicator() : Container(),
          ],
        ),
      ),
    );
  }
}
