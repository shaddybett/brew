import 'package:flutter/material.dart';
import 'package:grocery_delivery_app/utils/constants/colors.dart';

class CustomAppBar extends StatelessWidget {
  VoidCallback onPressed;
   CustomAppBar({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
   return Container(
      color: backgroundColor,
      width: MediaQuery.of(context).size.width,
      height: 50,
      child:GestureDetector(
        onTap: onPressed,
        child: Align(
          alignment: Alignment.centerLeft, child: Icon(Icons.arrow_back_ios)),
      ),// IconButton(onPressed: onPressed, icon: Image.asset('assets/images/arrow_back.png')),
    );
    // return AppBar(
    //   backgroundColor: backgroundColor,
    //   leading: IconButton(onPressed: onPressed, icon: Image.asset('assets/images/arrow_back.png')),
    // );
  }
}