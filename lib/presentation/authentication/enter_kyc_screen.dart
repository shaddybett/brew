// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../repository/auth/firebase_auth_service.dart';
// import '../../router/app_router.dart';
// import '../../utils/constants/customsnackbar.dart';
// import '../../utils/widgets/authentication/custom_textfield.dart';

// class EnterKYCPage extends StatefulWidget {
//   const EnterKYCPage({super.key});

//   @override
//   State<EnterKYCPage> createState() => _EnterKYCPageState();
// }

// class _EnterKYCPageState extends State<EnterKYCPage> {
//   final FirebaseAuthService authService = FirebaseAuthService();
//   TextEditingController passwordController = TextEditingController();
//   TextEditingController firstnameController = TextEditingController();
//   TextEditingController lastnameController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController confirmpasswordController = TextEditingController();
//   bool isLoading = false;

//   Future<String?> getPhoneNumber() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('phone');
//   }

//   void registerUser() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       User? user = await authService.registerWithEmailPassword(
//         emailController.text,
//         passwordController.text,
//       );

//       if (user != null) {
//         await user.sendEmailVerification();
//         String? phoneNumber = await getPhoneNumber();

//         FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//           'firstname': firstnameController.text,
//           'lastname': lastnameController.text,
//           'email': emailController.text,
//           "phoneNumber": phoneNumber,
//           "verified": false,
//         });

//         showCustomSnackbar(context, "Registration successful. Please check your email.");
//         Navigator.pushNamed(context, AppRouter.login);
//       }
//     } catch (error) {
//       showCustomSnackbar(context, "Registration failed: $error");
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Enter Details")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             CustomTextField(controller: firstnameController, hint: "First Name", title: "First Name"),
//             CustomTextField(controller: lastnameController, hint: "Last Name",title: "Last Name"),
//             CustomTextField(controller: emailController, hint: "Email", keyboardType: TextInputType.emailAddress,title: "Email",),
//             CustomTextField(controller: passwordController, hint: "Password", isPassword: true, title: "password"),
//             ElevatedButton(onPressed: registerUser, child: Text("Sign Up")),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../repository/auth/firebase_auth_service.dart';
import '../../router/app_router.dart';
import '../../utils/constants/customsnackbar.dart';
import '../../utils/widgets/authentication/custom_textfield.dart';
import '../../providers/auth_provider.dart'; // Import the AuthProvider

class EnterKYCPage extends StatefulWidget {
  const EnterKYCPage({super.key});

  @override
  State<EnterKYCPage> createState() => _EnterKYCPageState();
}

class _EnterKYCPageState extends State<EnterKYCPage> {
  final FirebaseAuthService authService = FirebaseAuthService();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;
  String? phoneNumber;
  bool showPassword = false;
  bool showConfirmPassword = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _getPhoneNumber();
  }

  Future<void> _getPhoneNumber() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      phoneNumber = prefs.getString('phone');
    });
  }

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
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  void registerUser() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Get the auth provider
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      
      // Register user with email and password
      final result = await authService.registerWithEmailPassword(
        emailController.text,
        passwordController.text,
      );
      
      final user = result.$1;
      final error = result.$2;
      
      if (user != null) {
        // Send email verification
        await user.sendEmailVerification();
        
        // Create user data map
        Map<String, dynamic> userData = {
          'firstname': firstnameController.text,
          'lastname': lastnameController.text,
          'email': emailController.text,
          'phoneNumber': phoneNumber,
          'verified': false,
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        // Update auth provider with user data
        await authProvider.createPhoneUser(user, userData);
        
        showCustomSnackbar(context, "Registration successful. Please check your email for verification.");
        Navigator.pushReplacementNamed(context, AppRouter.login);
      } else {
        showCustomSnackbar(context, "Registration failed: ${error ?? 'Unknown error'}");
      }
    } catch (error) {
      showCustomSnackbar(context, "Registration failed: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complete Your Profile"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create your account",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Fill in your details to complete registration",
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 24),
                
                // Phone number display
                if (phoneNumber != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.phone, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            "Verified phone: $phoneNumber",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // First name
                CustomTextField(
                  controller: firstnameController,
                  hint: "Enter your first name",
                  title: "First Name",
                  validator: _validateName,
                ),
                SizedBox(height: 16),
                
                // Last name
                CustomTextField(
                  controller: lastnameController,
                  hint: "Enter your last name",
                  title: "Last Name",
                  validator: _validateName,
                ),
                SizedBox(height: 16),
                
                // Email
                CustomTextField(
                  controller: emailController,
                  hint: "Enter your email address",
                  keyboardType: TextInputType.emailAddress,
                  title: "Email",
                  validator: _validateEmail,
                ),
                SizedBox(height: 16),
                
                // Password
                CustomTextField(
                  controller: passwordController,
                  hint: "Create a strong password",
                  isPassword: !showPassword,
                  title: "Password",
                  validator: _validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                  ),
                ),
                SizedBox(height: 16),
                
                // Confirm Password
                CustomTextField(
                  controller: confirmPasswordController,
                  hint: "Confirm your password",
                  isPassword: !showConfirmPassword,
                  title: "Confirm Password",
                  validator: _validateConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(showConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        showConfirmPassword = !showConfirmPassword;
                      });
                    },
                  ),
                ),
                SizedBox(height: 24),
                
                // Register button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : registerUser,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      disabledBackgroundColor: Colors.grey,
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
                            "Complete Registration",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                SizedBox(height: 16),
                
                // Already have account
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRouter.login);
                    },
                    child: Text("Already have an account? Login"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}