import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DoctorDashboard extends StatefulWidget {
  @override
  _DoctorDashboardState createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  String _doctorName = '';
  String _service = '';
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _selectedSession = 'All';
  List<Map<String, dynamic>> appointments = [];
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _serviceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _loadDoctorProfile();
    _initializeFCM();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> _initializeFCM() async {
    // Request permission for iOS if necessary
    await _firebaseMessaging.requestPermission();

    // Configure Firebase messaging
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground notifications
      if (message.notification != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(message.notification!.title ?? 'Notification'),
              content: Text(message.notification!.body ?? 'You have a new update'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Ok'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  Future<void> _loadDoctorProfile() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doctorDoc = await _firestore.collection('doctors').doc(user.uid).get();
      if (doctorDoc.exists) {
        Map<String, dynamic>? doctorData = doctorDoc.data() as Map<String, dynamic>?;
        if (doctorData != null) {
          setState(() {
            _doctorName = doctorData['doctors'] ?? 'No doctor';
            _service = doctorData['service'] ?? 'No Service';
            _nameController.text = _doctorName;
            _serviceController.text = _service;
          });
        } else {
          print('Doctor data is null');
        }
      } else {
        print('Doctor document does not exist');
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('doctors').doc(user.uid).update({
          'doctor': _nameController.text,
          'service': _serviceController.text,
        });
        setState(() {
          _doctorName = _nameController.text;
          _service = _serviceController.text;
        });
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      }
    }
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('appointments')
          .where('doctorName', isEqualTo: _doctorName)
          .where('service', isEqualTo: _service)
          .get();

      setState(() {
        appointments = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching appointments: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load appointments')),
      );
    }
  }

  Future<void> _rescheduleAppointment(String appointmentId, DateTime newDateTime) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'date': newDateTime.toIso8601String(),
        'time': DateFormat('HH:mm').format(newDateTime),
      });

      // Send a notification after rescheduling
      await _sendNotification(appointmentId, 'Your appointment has been rescheduled.');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment rescheduled successfully')),
      );
      _fetchAppointments();
    } catch (e) {
      print('Error rescheduling appointment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reschedule appointment')),
      );
    }
  }

  Future<void> _sendNotification(String appointmentId, String message) async {
    try {
      // You should trigger this via Firebase Cloud Functions or your backend, not directly in Flutter.
      // Send a notification to the topic related to the appointment ID using your server or Firebase Cloud Functions
      print("Send notification: $message for appointment $appointmentId");

      // If you're using Firebase Cloud Functions:
      // 1. Send the message from Cloud Functions to the patient (this can be done using Firebase Admin SDK)
      // Example structure of the notification could be handled in the backend instead of within the Flutter app.
      // For now, you can log a message to test.

    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment cancelled successfully')),
      );
      _fetchAppointments(); // Refresh the appointments list
    } catch (e) {
      print('Error cancelling appointment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel appointment')),
      );
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _serviceController,
                  decoration: InputDecoration(labelText: 'Service'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your service';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: _updateProfile,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dr. $_doctorName\'s Dashboard'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _showEditProfileDialog,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 20),
              _buildFilters(),
              const SizedBox(height: 20),
              _buildViewAppointmentsButton(),
              const SizedBox(height: 20),
              _buildAppointmentList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _fetchAppointments,
        label: Text('View Appointments'),
        icon: Icon(Icons.access_time),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.teal.shade50,
              child: Icon(Icons.medical_services, size: 50, color: Colors.teal),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: $_doctorName', style: TextStyle(fontSize: 16)),
                Text('Service: $_service', style: TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(labelText: 'Date'),
            controller: TextEditingController(text: _selectedDate),
            onTap: () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (selectedDate != null) {
                setState(() {
                  _selectedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
                });
              }
            },
          ),
        ),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: _selectedSession,
          items: ['All', 'Morning', 'Afternoon', 'Evening']
              .map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSession = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildViewAppointmentsButton() {
    return ElevatedButton(
      onPressed: _fetchAppointments,
      child: Text('Fetch Appointments'),
    );
  }

  Widget _buildAppointmentList() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : appointments.isEmpty
        ? Center(child: Text('No appointments available.'))
        : ListView.builder(
      shrinkWrap: true,
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final appointmentId = appointment['id'];
        return ListTile(
          title: Text(appointment['patientName']),
          subtitle: Text(
            'Date: ${appointment['date']} at ${appointment['time']}',
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _cancelAppointment(appointmentId),
          ),
          onTap: () {
            // Reschedule appointment
            _rescheduleAppointment(appointmentId, DateTime.now().add(Duration(days: 1)));
          },
        );
      },
    );
  }
}
