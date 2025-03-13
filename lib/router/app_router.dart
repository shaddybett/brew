import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:grocery_delivery_app/presentation/authentication/phone_screen.dart';
import 'package:grocery_delivery_app/presentation/authentication/otp_screen.dart';
import 'package:grocery_delivery_app/presentation/authentication/enter_kyc_screen.dart';
import 'package:grocery_delivery_app/presentation/authentication/login_screen.dart';
import 'package:grocery_delivery_app/presentation/home/home_screen.dart';
import 'package:grocery_delivery_app/presentation/cart/cart_screen.dart';
import 'package:grocery_delivery_app/presentation/checkout/checkout_screen.dart';
import 'package:grocery_delivery_app/presentation/products/product_list_screen.dart';
import 'package:grocery_delivery_app/presentation/splash.dart';

class AppRouter {
  static const String initial = "/";
  static const String phone = "/phone";
  static const String login = "/login";
  static const String otpscreen = "/otpscreen";
  static const String kycpage = "/kycpage";
  static const String home = "/home";
  static const String products = "/products";
  static const String cart = "/cart";
  static const String checkout = "/checkout";

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    Logger logger = Logger();
    logger.w("Navigating to: ${settings.name}");

    switch (settings.name) {
      case initial:
        return _slideRoute(SplashScreen());
      case phone:
        return _slideRoute(PhoneScreen());
      case login:
        return _slideRoute(LoginScreen());
      case otpscreen:
        return _slideRoute(OtpScreen(verificationCode: args as String));
      case kycpage:
        return _slideRoute(EnterKYCPage());
      case home:
        return _slideRoute(HomeScreen());
      case products:
        return _slideRoute(ProductListScreen());
      case cart:
        return _slideRoute(CartScreen());
      case checkout:
        return _slideRoute(CheckoutScreen());

      default:
        return _slideRoute(HomeScreen()); // Fallback route
    }
  }

  static Route _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  static void pop(BuildContext context) {
    Navigator.pop(context);
  }
}
