// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:grocery_delivery_app/router/app_router.dart';
// import 'package:grocery_delivery_app/utils/widgets/authentication/otp_field.dart';
// import '../../utils/constants/customsnackbar.dart';

// class OtpScreen extends StatefulWidget {
//   final String verificationCode;
//   const OtpScreen({super.key, required this.verificationCode});

//   @override
//   State<OtpScreen> createState() => _OtpScreenState();
// }

// class _OtpScreenState extends State<OtpScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   bool isLoading = false;

//   void verifyOtp(String otp) async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: widget.verificationCode,
//         smsCode: otp,
//       );
//       await _auth.signInWithCredential(credential);
//       Navigator.pushNamed(context, AppRouter.kycpage);
//     } catch (e) {
//       showCustomSnackbar(context, "Invalid OTP. Please try again.");
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Enter OTP")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             OTPField(verificationId: widget.verificationCode),
//             SizedBox(height: 20),
//             isLoading ? CircularProgressIndicator() : Container(),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_delivery_app/repository/auth/firebase_auth_service.dart';
import 'package:grocery_delivery_app/router/app_router.dart';
import 'package:grocery_delivery_app/utils/widgets/authentication/otp_field.dart';
import '../../utils/constants/customsnackbar.dart';

class OtpScreen extends StatefulWidget {
  final String verificationCode;
  final String? phoneNumber;
  
  const OtpScreen({
    super.key, 
    required this.verificationCode,
    this.phoneNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool isLoading = false;
  int _remainingTime = 60;
  Timer? _timer;
  String _maskedPhone = "";

  @override
  void initState() {
    super.initState();
    startTimer();
    _maskPhoneNumber();
  }

  void _maskPhoneNumber() {
    if (widget.phoneNumber != null && widget.phoneNumber!.length > 6) {
      String phone = widget.phoneNumber!;
      _maskedPhone = "${phone.substring(0, 4)}****${phone.substring(phone.length - 2)}";
    } else {
      _maskedPhone = "your phone";
    }
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void resendOTP() {
    if (_remainingTime <= 0 && widget.phoneNumber != null) {
      setState(() {
        isLoading = true;
      });
      
      _authService.resendOTP(
        widget.phoneNumber!,
        context,
        (verificationId, resendToken) {
          setState(() {
            isLoading = false;
            _remainingTime = 60;
          });
          startTimer();
          showCustomSnackbar(context, "OTP resent successfully");
        },
        (errorMessage) {
          setState(() {
            isLoading = false;
          });
          showCustomSnackbar(context, errorMessage);
        },
      );
    }
  }

  void verifyOtp(String otp) async {
    setState(() {
      isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationCode,
        smsCode: otp,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        Navigator.pushNamedAndRemoveUntil(
          context, 
          AppRouter.kycpage, 
          (route) => false
        );
      } else {
        showCustomSnackbar(context, "Invalid OTP. Please try again.");
      }
    } catch (e) {
      showCustomSnackbar(context, "Invalid OTP. Please try again.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify OTP"),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter verification code",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "We've sent a 6-digit code to $_maskedPhone",
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            OTPField(
              verificationId: widget.verificationCode,
              onComplete: verifyOtp,
            ),
            SizedBox(height: 20),
            if (isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Didn't receive code? "),
                _remainingTime > 0
                    ? Text(
                        "Resend in $_remainingTime seconds",
                        style: TextStyle(color: Colors.grey),
                      )
                    : TextButton(
                        onPressed: resendOTP,
                        child: Text("Resend OTP"),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
