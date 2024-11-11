import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart' as home;
import 'admin_dashboard.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  // Fetch user's role from Firestore
  Future<String> getUserRole(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        print("User document does not exist for uid: $uid");
        await createUserDocument(uid, 'patient');
        return 'patient';
      }

      return userDoc.data()?['role'] ?? 'patient';
    } catch (e) {
      print("Error fetching user role: $e");
      return 'patient';
    }
  }

  // Create a new user document with a default role
  Future<void> createUserDocument(String uid, String role) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("Created user document for uid: $uid with role: $role");
    } catch (e) {
      print("Error creating user document: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade300, Colors.purple.shade300],
                ),
              ),
              child: SignInScreen(
                providers: [
                  EmailAuthProvider(),
                  GoogleProvider(clientId: "YOUR_CLIENT_ID"),
                ],
                headerBuilder: (context, constraints, _) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 50,
                          child: Image(
                            image: AssetImage('assets/images/logo.png'),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                subtitleBuilder: (context, action) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: action == AuthAction.signIn
                        ? const Text(
                      'Welcome back! Please sign in to continue.',
                      style: TextStyle(color: Colors.white),
                    )
                        : const Text(
                      'Welcome! Please create an account to get started.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
                footerBuilder: (context, action) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'By signing in, you agree to our terms and conditions.',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
                sideBuilder: (context, constraints) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset(
                        'assets/images/side_image.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }

        final user = snapshot.data!;
        print("User is authenticated with UID: ${user.uid}");

        return FutureBuilder<String>(
          future: getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (roleSnapshot.hasError) {
              print("Error fetching role: ${roleSnapshot.error}");
              return const Center(child: Text('An error occurred. Please try again.'));
            }

            final userRole = roleSnapshot.data!;
            print("User role fetched: $userRole");

            switch (userRole) {
              case 'admin':
                return const AdminDashboard();
              case 'patient':
                return home.HomeScreen(userId: user.uid);
              default:
                return const Center(
                  child: Text('User role not recognized. Please contact support.'),
                );
            }
          },
        );
      },
    );
  }
}