import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _licenseNumber = '';
  String _mobileNumber = '';
  bool _isDoctor = false;
  bool _isCreatingAccount = false;
  bool _isPasswordVisible = false;

  // Define custom colors
  final primaryColor = Color(0xFF6C63FF); // Modern purple
  final secondaryColor = Color(0xFF2A2A72); // Deep blue
  final backgroundColor = Color(0xFFF5F6F9); // Light gray background
  final cardColor = Colors.white;
  final errorColor = Color(0xFFFF6B6B); // Soft red for errors

  void _toggleUserType() => setState(() => _isDoctor = !_isDoctor);
  void _toggleAccountCreation() => setState(() => _isCreatingAccount = !_isCreatingAccount);
  void _togglePasswordVisibility() => setState(() => _isPasswordVisible = !_isPasswordVisible);

  // Custom input decoration
  InputDecoration _getInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: cardColor,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: primaryColor),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        late UserCredential userCredential;
        if (_isCreatingAccount) {
          userCredential = await _auth.createUserWithEmailAndPassword(
            email: _email,
            password: _password,
          );

          await _firestore.collection(_isDoctor ? 'doctors' : 'patients').doc(userCredential.user!.uid).set({
            'email': _email,
            'userType': _isDoctor ? 'doctor' : 'patient',
            if (_isDoctor) 'licenseNumber': _licenseNumber,
            if (!_isDoctor) 'mobileNumber': _mobileNumber,
          });
        } else {
          userCredential = await _auth.signInWithEmailAndPassword(
            email: _email,
            password: _password,
          );
        }

        DocumentSnapshot userDoc = await _firestore
            .collection(_isDoctor ? 'doctors' : 'patients')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          String userType = userData['userType'] as String;

          if (userType == 'doctor') {
            Navigator.of(context).pushReplacementNamed('/doctorDashboard');
          } else {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        } else {
          throw Exception('User data not found');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, secondaryColor],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.08,
                  vertical: 24,
                ),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // App Logo
                          Icon(
                            Icons.medical_services,
                            size: 64,
                            color: primaryColor,
                          ),
                          SizedBox(height: 16),
                          // App Title
                          Text(
                            'Health Hub',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: secondaryColor,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _isCreatingAccount ? 'Create Account' : 'Welcome Back',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 32),

                          // Email Field
                          TextFormField(
                            decoration: _getInputDecoration(
                              hint: 'Email',
                              icon: Icons.email_rounded,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Please enter your email';
                              if (!EmailValidator.validate(value!)) return 'Please enter a valid email';
                              return null;
                            },
                            onSaved: (value) => _email = value!,
                          ),
                          SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            decoration: _getInputDecoration(
                              hint: 'Password',
                              icon: Icons.lock_rounded,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                  color: primaryColor,
                                ),
                                onPressed: _togglePasswordVisibility,
                              ),
                            ),
                            obscureText: !_isPasswordVisible,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Please enter your password';
                              if (value!.length < 6) return 'Password must be at least 6 characters';
                              return null;
                            },
                            onChanged: (value) => _password = value,
                          ),
                          SizedBox(height: 16),

                          // Confirm Password Field (Sign up only)
                          if (_isCreatingAccount) ...[
                            TextFormField(
                              decoration: _getInputDecoration(
                                hint: 'Confirm Password',
                                icon: Icons.lock_rounded,
                              ),
                              obscureText: !_isPasswordVisible,
                              validator: (value) {
                                if (value != _password) return 'Passwords do not match';
                                return null;
                              },
                              onChanged: (value) => _confirmPassword = value,
                            ),
                            SizedBox(height: 16),
                          ],

                          // License Number Field (Doctors only)
                          if (_isDoctor) ...[
                            TextFormField(
                              decoration: _getInputDecoration(
                                hint: 'License Number',
                                icon: Icons.badge_rounded,
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Please enter your license number';
                                if (!value!.startsWith('DOC') || value.length != 8) {
                                  return 'License must start with DOC and be 8 characters';
                                }
                                return null;
                              },
                              onSaved: (value) => _licenseNumber = value!,
                            ),
                            SizedBox(height: 16),
                          ],

                          // Mobile Number Field (Patients only)
                          if (!_isDoctor && _isCreatingAccount) ...[
                            TextFormField(
                              decoration: _getInputDecoration(
                                hint: 'Mobile Number',
                                icon: Icons.phone_rounded,
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Please enter your mobile number';
                                return null;
                              },
                              onSaved: (value) => _mobileNumber = value!,
                            ),
                            SizedBox(height: 16),
                          ],

                          // User Type Switch
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Patient', style: TextStyle(color: !_isDoctor ? primaryColor : Colors.grey)),
                                Switch(
                                  value: _isDoctor,
                                  onChanged: (value) => _toggleUserType(),
                                  activeColor: primaryColor,
                                ),
                                Text('Doctor', style: TextStyle(color: _isDoctor ? primaryColor : Colors.grey)),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),

                          // Submit Button
                          ElevatedButton(
                            onPressed: _submitForm,
                            child: Text(
                              _isCreatingAccount ? 'Create Account' : 'Login',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              minimumSize: Size(double.infinity, 50),
                            ),
                          ),
                          SizedBox(height: 16),

                          // Toggle Account Creation
                          TextButton(
                            onPressed: _toggleAccountCreation,
                            child: Text(
                              _isCreatingAccount
                                  ? 'Already have an account? Login'
                                  : 'Don\'t have an account? Sign up',
                              style: TextStyle(color: primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}