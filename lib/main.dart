import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:grocery_delivery_app/firebase_options.dart';
import 'package:grocery_delivery_app/providers/auth_provider.dart';
import 'package:grocery_delivery_app/providers/cart_provider.dart';
import 'package:grocery_delivery_app/providers/product_provider.dart';
import 'package:grocery_delivery_app/router/app_router.dart';
import 'package:grocery_delivery_app/utils/constants/colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(EasyLocalization(
    path: 'assets/lang',
    supportedLocales: const [Locale('en')],
    fallbackLocale: const Locale('en'),
    useFallbackTranslations: true,
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    final notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      await Permission.notification.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
      ],
      child: MaterialApp(
        initialRoute: AppRouter.initial,
        onGenerateRoute: AppRouter.onGenerateRoute,
        title: 'Grocery Delivery',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData(
          primaryColor: primaryColor,
          fontFamily: 'SpaceGrotesk',
        ),
      ),
    );
  }
}
