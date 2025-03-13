// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';

// import '../../constants/colors.dart';
// import '../../constants/textutil.dart';

// class PhoneField extends StatefulWidget {
//   final TextEditingController phoneController;
//   const PhoneField({super.key, required this.phoneController});

//   @override
//   State<PhoneField> createState() => _PhonefieldState();
// }

// class _PhonefieldState extends State<PhoneField> {
//   bool validphone = false;
//   bool _showPhoneNoErrorText = false;
//   String _selectedCountryCode = "+254";

//   _hidePhoneNumberErrorMessage() {
//     setState(() {
//       _showPhoneNoErrorText = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return IntlPhoneField(
//       controller: widget.phoneController,
//       disableLengthCheck: true,
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: Colors.white,
//         enabledBorder: OutlineInputBorder(
//           borderRadius: const BorderRadius.all(Radius.circular(10.0)),
//           borderSide: BorderSide(width: 1, color: Colors.white),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: const BorderRadius.all(Radius.circular(10.0)),
//           borderSide: BorderSide(width: 1, color: primaryColor),
//         ),
//         labelText: "register.enter_phone".tr(),
//         hintText: 'e.g 700000000',
//         hintStyle: AppTextStyles.smallLight.copyWith(color: Colors.grey),
//       ),
//       initialCountryCode: 'KE',
//       autovalidateMode: AutovalidateMode.onUserInteraction,
//       validator: (phone) {
//         if (phone!.number.length != 9) {
//           setState(() {
//             validphone = false;
//           });
//           return 'Enter a valid phone number (9 digits)';
//         } else {
//           setState(() {
//             validphone = true;
//           });
//         }
//         return null;
//       },
//       onChanged: (phone) {
//         _hidePhoneNumberErrorMessage();
//       },
//       onCountryChanged: (country) {
//         _selectedCountryCode = "+${country.fullCountryCode}";
//         _hidePhoneNumberErrorMessage();
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneField extends StatelessWidget {
  final TextEditingController phoneController;
  final Function(String)? onChanged;
  final String hint;
  final String prefix;

  const PhoneField({
    Key? key,
    required this.phoneController,
    this.onChanged,
    this.hint = "Phone number",
    this.prefix = "+254",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Text(
              prefix,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}