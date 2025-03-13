// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:grocery_delivery_app/repository/auth/firebase_auth_service.dart';

// class AuthProvider extends ChangeNotifier {
//   final FirebaseAuthService _authService = FirebaseAuthService();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
//   User? _user;
//   Map<String, dynamic>? _userData;
//   bool _isLoading = false;

//   User? get user => _user;
//   Map<String, dynamic>? get userData => _userData;
//   bool get isLoading => _isLoading;
//   bool get isLoggedIn => _user != null;

//   AuthProvider() {
//     _initializeUser();
//   }

//   void _initializeUser() async {
//     _user = _authService.getCurrentUser();
//     if (_user != null) {
//       await _fetchUserData();
//     }
//     notifyListeners();
//   }

//   Future<void> _fetchUserData() async {
//     if (_user == null) return;
    
//     try {
//       _isLoading = true;
//       notifyListeners();
      
//       DocumentSnapshot doc = await _firestore.collection('users').doc(_user!.uid).get();
//       if (doc.exists) {
//         _userData = doc.data() as Map<String, dynamic>;
//       }
//     } catch (e) {
//       print("Error fetching user data: $e");
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> signInWithEmailPassword(String email, String password) async {
//     try {
//       _isLoading = true;
//       notifyListeners();
      
//       _user = await _authService.registerWithEmailPassword(email, password);
//       if (_user != null) {
//         await _fetchUserData();
//         return true;
//       }
//       return false;
//     } catch (e) {
//       print("Login error: $e");
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> register(String email, String password, Map<String, dynamic> userData) async {
//     try {
//       _isLoading = true;
//       notifyListeners();
      
//       _user = await _authService.registerWithEmailPassword(email, password);
//       if (_user != null) {
//         // Add user data to Firestore
//         await _firestore.collection('users').doc(_user!.uid).set(userData);
//         _userData = userData;
//         return true;
//       }
//       return false;
//     } catch (e) {
//       print("Registration error: $e");
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> signOut() async {
//     try {
//       await _authService.signOut();
//       _user = null;
//       _userData = null;
//       notifyListeners();
//     } catch (e) {
//       print("Sign out error: $e");
//     }
//   }
// }



import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_delivery_app/repository/auth/firebase_auth_service.dart';

class AppAuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get errorMessage => _errorMessage;

  AppAuthProvider() {
    _initializeUser();
  }

  void _initializeUser() async {
    _user = _authService.getCurrentUser();
    if (_user != null) {
      await _fetchUserData();
    }
    notifyListeners();
  }

  Future<void> _fetchUserData() async {
    if (_user == null) return;
    
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      DocumentSnapshot doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _userData = doc.data() as Map<String, dynamic>;
      } else {
        // Create a basic user document if it doesn't exist yet
        // This handles phone auth users who might not have a document
        Map<String, dynamic> basicData = {
          'uid': _user!.uid,
          'phoneNumber': _user!.phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
        };
        await _firestore.collection('users').doc(_user!.uid).set(basicData);
        _userData = basicData;
      }
    } catch (e) {
      _errorMessage = "Failed to fetch user data: ${e.toString()}";
      print("Error fetching user data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to update user data
  Future<bool> updateUserData(Map<String, dynamic> newData) async {
    if (_user == null) return false;
    
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await _firestore.collection('users').doc(_user!.uid).update(newData);
      
      // Update local data
      _userData = {...?_userData, ...newData};
      return true;
    } catch (e) {
      _errorMessage = "Failed to update user data: ${e.toString()}";
      print("Error updating user data: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final result = await _authService.signInWithEmailPassword(email, password);
      _user = result.$1;
      _errorMessage = result.$2;
      
      if (_user != null) {
        await _fetchUserData();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = "Login failed: ${e.toString()}";
      print("Login error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, Map<String, dynamic> userData) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final result = await _authService.registerWithEmailPassword(email, password);
      _user = result.$1;
      _errorMessage = result.$2;
      
      if (_user != null) {
        // Add user data to Firestore
        userData['uid'] = _user!.uid;
        userData['email'] = email;
        userData['createdAt'] = FieldValue.serverTimestamp();
        
        await _firestore.collection('users').doc(_user!.uid).set(userData);
        _userData = userData;
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = "Registration failed: ${e.toString()}";
      print("Registration error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to handle phone auth user creation
  Future<bool> createPhoneUser(User user, Map<String, dynamic> userData) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _user = user;
      
      // Add user data to Firestore
      userData['uid'] = user.uid;
      userData['phoneNumber'] = user.phoneNumber;
      userData['createdAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection('users').doc(user.uid).set(userData);
      _userData = userData;
      return true;
    } catch (e) {
      _errorMessage = "Failed to create user profile: ${e.toString()}";
      print("Phone user creation error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to handle when a user signs in with phone
  Future<void> handlePhoneSignIn(User user) async {
    _user = user;
    await _fetchUserData();
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await _authService.signOut();
      _user = null;
      _userData = null;
    } catch (e) {
      _errorMessage = "Sign out failed: ${e.toString()}";
      print("Sign out error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}