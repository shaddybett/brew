// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:pinput/pinput.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../../router/app_router.dart';

// class OTPField extends StatefulWidget {
//   final String verificationId;
//   const OTPField({Key? key, required this.verificationId}) : super(key: key);

//   @override
//   State<OTPField> createState() => _OTPFieldState();
// }

// class _OTPFieldState extends State<OTPField> {
//   String otp = '';
//   final TextEditingController _otpController = TextEditingController();
//   Timer? _timer;
//   ValueNotifier<int> _remainingSeconds = ValueNotifier(30);

//   @override
//   void initState() {
//     super.initState();
//     _startTimer();
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (_remainingSeconds.value > 0) {
//         _remainingSeconds.value--;
//       } else {
//         _timer?.cancel();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Time out. Please request OTP again.")),
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _otpController.dispose();

//     _timer?.cancel();
//     _remainingSeconds.dispose();
//     super.dispose();
//   }

//   Future<void> verifyOTP() async {
//     if (otp.length == 6) {
//       try {
//         PhoneAuthCredential credential = PhoneAuthProvider.credential(
//           verificationId: widget.verificationId,
//           smsCode: otp,
//         );

//         await FirebaseAuth.instance.signInWithCredential(credential);
//         _timer?.cancel();

//         Navigator.pushNamed(context, AppRouter.kycpage);
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to verify OTP: $e")),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
//           child: Pinput(
//             length: 6,
//             controller: _otpController,
//             onCompleted: (pin) {
//               otp = pin;
//               verifyOTP();
//             },
//             pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
//             pinAnimationType: PinAnimationType.scale,
//             defaultPinTheme: PinTheme(
//               width: 56,
//               height: 56,
//               textStyle: TextStyle(
//                   fontSize: 20,
//                   color: Color.fromRGBO(30, 60, 87, 1),
//                   fontWeight: FontWeight.w600),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 border: Border.all(color: Colors.grey[500]!),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//             ),
//           ),
//         ),
//         ValueListenableBuilder<int>(
//           valueListenable: _remainingSeconds,
//           builder: (_, remainingSeconds, __) => Padding(
//             padding: const EdgeInsets.only(top: 8.0),
//             child: Text(
//               'Please enter the OTP within $remainingSeconds seconds.',
//               style: TextStyle(color: Colors.grey[600]),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPField extends StatelessWidget {
  final String verificationId;
  final Function(String) onComplete;

  const OTPField({
    Key? key,
    required this.verificationId,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: 6,
      keyboardType: TextInputType.number,
      animationType: AnimationType.fade,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(8),
        fieldHeight: 50,
        fieldWidth: 45,
        activeFillColor: Colors.white,
        inactiveFillColor: Colors.white,
        selectedFillColor: Colors.white,
        activeColor: Theme.of(context).primaryColor,
        inactiveColor: Colors.grey.shade300,
        selectedColor: Theme.of(context).primaryColor,
      ),
      animationDuration: Duration(milliseconds: 300),
      enableActiveFill: true,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onCompleted: onComplete,
      onChanged: (value) {},
    );
  }
}