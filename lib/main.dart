import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'auth_gate.dart';
import 'onboarding_screen.dart';
import 'welcome_screen.dart';
import 'login_page.dart';
import 'daily_mood_logging_screen.dart';
import 'chat_screen.dart';
import 'appointment_booking_screen.dart';
import 'locate_hospital_screen.dart' as locate;
import 'emergency_contacts_screen.dart' as emergency;
import 'calendar_screen.dart';
import 'legal_support_screen.dart';
import 'admin_dashboard.dart';
import 'doctor_dashboard.dart';
import 'home_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Configure Firebase Messaging
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission for iOS devices
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    String? token = await messaging.getToken();
    print("FCM Token: $token");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received a message in the foreground: ${message.notification?.title}");
    });

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppointmentCartProvider()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Error initializing Firebase or messaging: $e');
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AppointmentCartProvider(),
          ),
        ],
        child: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Connect',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(userId: ''),
        '/auth': (context) => const AuthGate(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => const HomeScreen(userId: ''),
        '/moodLogging': (context) => const MoodLoggingScreen(),
        '/chat': (context) => ChatScreen(
          therapistName: ModalRoute.of(context)?.settings.arguments as String? ?? '',
        ),
        '/appointmentBooking': (context) => AppointmentBookingScreen(
          cartProvider: Provider.of<AppointmentCartProvider>(context),
        ),
        '/locateHospital': (context) => const locate.LocateHospitalScreen(),
        '/emergencyContacts': (context) => emergency.EmergencyContactsScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/legalSupport': (context) => const LegalSupportScreen(),
        '/adminDashboard': (context) => const AdminDashboard(),
        '/doctorDashboard': (context) => DoctorDashboard(),
      },
    );
  }
}