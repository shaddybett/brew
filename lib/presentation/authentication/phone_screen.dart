// import 'package:flutter/material.dart';
// import 'package:grocery_delivery_app/repository/auth/firebase_auth_service.dart';
// import 'package:grocery_delivery_app/router/app_router.dart';
// import 'package:grocery_delivery_app/utils/widgets/authentication/phone_field.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../utils/constants/customsnackbar.dart';

// class PhoneScreen extends StatefulWidget {
//   const PhoneScreen({super.key});

//   @override
//   State<PhoneScreen> createState() => _PhoneScreenState();
// }

// class _PhoneScreenState extends State<PhoneScreen> {
//   final FirebaseAuthService authService = FirebaseAuthService();
//   bool validPhone = false;
//   bool isLoading = false;
//   String phoneNum = "";
//   TextEditingController phoneController = TextEditingController();

//   validatePhone(String phone) {
//     if (phone.length != 9) {
//       setState(() {
//         validPhone = false;
//       });
//       return 'Enter a valid phone number (9 digits)';
//     } else {
//       setState(() {
//         validPhone = true;
//         phoneNum = "+254" + phone;
//       });
//     }
//   }

//   Future<void> _savePhone(String phone) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('phone', phone);
//   }

//   void initiateSignIn() {
//     validatePhone(phoneController.text);
//     if (validPhone) {
//       _savePhone(phoneNum);
//       setState(() {
//         isLoading = true;
//       });

//       authService.signInWithPhone(
//         phoneNum,
//         context,
//         (verificationId, resendToken) {
//           setState(() {
//             isLoading = false;
//           });
//           Navigator.pushNamed(context, AppRouter.otpscreen, arguments: verificationId);
//         },
//         (errorMessage) {
//           setState(() {
//             isLoading = false;
//           });
//           showCustomSnackbar(context, errorMessage);
//         },
//       );
//     } else {
//       showCustomSnackbar(context, 'Please enter a valid phone number (9 digits)');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Phone Verification")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             PhoneField(phoneController: phoneController),
//             SizedBox(height: 20),
//             isLoading ? CircularProgressIndicator() : ElevatedButton(
//               onPressed: initiateSignIn,
//               child: Text("Continue"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:grocery_delivery_app/repository/auth/firebase_auth_service.dart';
import 'package:grocery_delivery_app/router/app_router.dart';
import 'package:grocery_delivery_app/utils/widgets/authentication/phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants/customsnackbar.dart';

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

  String? validatePhone(String phone) {
    if (phone.isEmpty) {
      setState(() {
        validPhone = false;
      });
      return 'Phone number cannot be empty';
    } else if (phone.length != 9) {
      setState(() {
        validPhone = false;
      });
      return 'Enter a valid phone number (9 digits)';
    } else {
      setState(() {
        validPhone = true;
        phoneNum = "+254$phone";
      });
    }
    return null;
  }

  Future<void> _savePhone(String phone) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone', phone);
  }

  void initiateSignIn() {
    String? errorMessage = validatePhone(phoneController.text);
    if (errorMessage == null) {
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
          Navigator.pushNamed(context, AppRouter.otpscreen, arguments: {
            'verificationId': verificationId,
            'phoneNumber': phoneNum,
          });
        },
        (errorMessage) {
          setState(() {
            isLoading = false;
          });
          showCustomSnackbar(context, errorMessage);
        },
      );
    } else {
      showCustomSnackbar(context, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phone Verification"),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter your phone number",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "We'll send you a verification code to confirm your identity",
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            PhoneField(
              phoneController: phoneController,
              onChanged: (value) {
                validatePhone(value);
              },
              hint: "9XXXXXXXX",
              prefix: "+254",
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : initiateSignIn,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        "Continue",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}