// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:provider/provider.dart';
// import 'package:grocery_delivery_app/repository/auth/firebase_auth_service.dart';
// import 'package:grocery_delivery_app/router/app_router.dart';
// import 'package:grocery_delivery_app/utils/constants/customsnackbar.dart';
// import 'package:grocery_delivery_app/utils/widgets/authentication/custom_textfield.dart';
// import 'package:grocery_delivery_app/providers/auth_provider.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final FirebaseAuthService authService = FirebaseAuthService();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool isLoading = false;
//   bool showPassword = false;
//   final _formKey = GlobalKey<FormState>();

//   /// Email validation
//   String? _validateEmail(String? value) {
//     if (value == null || value.isEmpty) return 'Email is required';
//     final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//     if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
//     return null;
//   }

//   /// Password validation
//   String? _validatePassword(String? value) {
//     if (value == null || value.isEmpty) return 'Password is required';
//     return null;
//   }

//   /// Handles login
//   void login() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);

//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final success = await authProvider.signInWithEmailPassword(
//         emailController.text,
//         passwordController.text,
//       );

//       if (success) {
//         Navigator.pushReplacementNamed(context, AppRouter.home);
//       } else {
//         showCustomSnackbar(
//           context,
//           authProvider.errorMessage ?? "Login failed. Check your credentials.",
//         );
//       }
//     } catch (error) {
//       showCustomSnackbar(context, "Login failed: $error");
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   /// Handles forgot password
//   void forgotPassword() async {
//     if (emailController.text.isEmpty) {
//       showCustomSnackbar(context, "Please enter your email address");
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
//       showCustomSnackbar(
//         context,
//         "Password reset email sent. Check your inbox.",
//         isError: false,
//       );
//     } catch (error) {
//       showCustomSnackbar(context, "Failed to send reset email: $error");
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Login")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 40),
//               const Text(
//                 "Welcome Back!",
//                 style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 "Sign in to continue",
//                 style: TextStyle(color: Colors.grey, fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 40),
//               CustomTextField(
//                 controller: emailController,
//                 hint: "Enter your email",
//                 keyboardType: TextInputType.emailAddress,
//                 title: "Email",
//                 validator: _validateEmail,
//                 prefixIcon: const Icon(Icons.email_outlined),
//               ),
//               const SizedBox(height: 16),
//               CustomTextField(
//                 controller: passwordController,
//                 hint: "Enter your password",
//                 isPassword: !showPassword,
//                 title: "Password",
//                 validator: _validatePassword,
//                 prefixIcon: const Icon(Icons.lock_outline),
//                 suffixIcon: IconButton(
//                   icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
//                   onPressed: () => setState(() => showPassword = !showPassword),
//                 ),
//               ),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: isLoading ? null : forgotPassword,
//                   child: const Text("Forgot Password?"),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: isLoading ? null : login,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 child: isLoading
//                     ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                       )
//                     : const Text("Login", style: TextStyle(fontSize: 16)),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text("Don't have an account?"),
//                   TextButton(
//                     onPressed: () => Navigator.pushReplacementNamed(context, AppRouter.phone),
//                     child: const Text("Sign up"),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 40),
//               const Row(
//                 children: [
//                   Expanded(child: Divider()),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16),
//                     child: Text("OR"),
//                   ),
//                   Expanded(child: Divider()),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               OutlinedButton.icon(
//                 onPressed: () => Navigator.pushReplacementNamed(context, AppRouter.phone),
//                 icon: const Icon(Icons.phone),
//                 label: const Text("Sign in with Phone"),
//                 style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }
// }



import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:grocery_delivery_app/repository/auth/firebase_auth_service.dart';
import 'package:grocery_delivery_app/router/app_router.dart';
import 'package:grocery_delivery_app/utils/constants/customsnackbar.dart';
import 'package:grocery_delivery_app/utils/widgets/authentication/custom_textfield.dart';
import 'package:grocery_delivery_app/providers/auth_provider.dart'; // Import AuthProvider

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuthService authService = FirebaseAuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool showPassword = false;
  final _formKey = GlobalKey<FormState>();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  void login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Use the AuthProvider instead of direct service call
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      
      final success = await authProvider.signInWithEmailPassword(
        emailController.text,
        passwordController.text,
      );

      if (success) {
        Navigator.pushReplacementNamed(context, AppRouter.home);
      } else {
        showCustomSnackbar(
          context, 
          authProvider.errorMessage ?? "Login failed. Please check your credentials."
        );
      }
    } catch (error) {
      showCustomSnackbar(context, "Login failed: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void forgotPassword() async {
    if (emailController.text.isEmpty) {
      showCustomSnackbar(context, "Please enter your email address");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text,
      );
      showCustomSnackbar(
        context, 
        "Password reset email sent. Please check your inbox.",
        // isError: false,
      );
    } catch (error) {
      showCustomSnackbar(context, "Failed to send reset email: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Sign in to continue",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: emailController,
                  hint: "Enter your email",
                  keyboardType: TextInputType.emailAddress,
                  title: "Email",
                  validator: _validateEmail,
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: passwordController,
                  hint: "Enter your password",
                  isPassword: !showPassword,
                  title: "Password",
                  validator: _validatePassword,
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading ? null : forgotPassword,
                    child: const Text("Forgot Password?"),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Login",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRouter.phone);
                      },
                      child: const Text("Sign up"),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("OR"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRouter.phone);
                  },
                  icon: Icon(Icons.phone),
                  label: Text("Sign in with Phone"),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}