import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppointmentCartProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Connect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Wrap the home widget with a Consumer to ensure provider is accessible
      home: Consumer<AppointmentCartProvider>(
        builder: (context, cartProvider, child) => AppointmentBookingScreen(
          cartProvider: cartProvider,
        ),
      ),
    );
  }
}

// Model classes
class Doctor {
  final String id;
  final String name;
  final String specialization;

  Doctor({required this.id, required this.name, required this.specialization});

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'],
      name: map['name'],
      specialization: map['specialization'],
    );
  }
}

class Service {
  final String id;
  final String name;
  final int maxSlotsPerSession;
  final List<String> doctorIds;

  Service({
    required this.id,
    required this.name,
    required this.maxSlotsPerSession,
    required this.doctorIds,
  });

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'],
      name: map['name'],
      maxSlotsPerSession: map['maxSlotsPerSession'],
      doctorIds: List<String>.from(map['doctorIds']),
    );
  }
}

class Appointment {
  final String id;
  final String patientName;
  final String phoneNumber;
  final int age;
  final String county;
  final String idNumber;
  final String serviceId;
  final String doctorId;
  final DateTime dateTime;
  final String session;

  Appointment({
    required this.id,
    required this.patientName,
    required this.phoneNumber,
    required this.age,
    required this.county,
    required this.idNumber,
    required this.serviceId,
    required this.doctorId,
    required this.dateTime,
    required this.session,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientName': patientName,
      'phoneNumber': phoneNumber,
      'age': age,
      'county': county,
      'idNumber': idNumber,
      'serviceId': serviceId,
      'doctorId': doctorId,
      'dateTime': dateTime,
      'session': session,
    };
  }
}

class AppointmentCartProvider extends ChangeNotifier {
  final List<Appointment> _appointments = [];
  List<Appointment> get appointments => List.unmodifiable(_appointments);

  void addAppointment(Appointment appointment) {
    try {
      if (!_appointments.any((a) => a.id == appointment.id)) {
        _appointments.add(appointment);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding appointment to cart: $e');
      rethrow;
    }
  }

  void removeAppointment(String id) {
    try {
      _appointments.removeWhere((appointment) => appointment.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing appointment from cart: $e');
      rethrow;
    }
  }

  void clearCart() {
    try {
      _appointments.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      rethrow;
    }
  }
}

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "YOUR_API_KEY",
        authDomain: "YOUR_AUTH_DOMAIN",
        projectId: "YOUR_PROJECT_ID",
        storageBucket: "YOUR_STORAGE_BUCKET",
        messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
        appId: "YOUR_APP_ID",
      ),
    );
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
    rethrow;
  }
}


class AppointmentBookingScreen extends StatefulWidget {
  final AppointmentCartProvider cartProvider;

  const AppointmentBookingScreen({
    super.key,
    required this.cartProvider,
  });

  @override
  _AppointmentBookingScreenState createState() => _AppointmentBookingScreenState();
}


class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _countyController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();

  String? _selectedService;
  String? _selectedDoctor;
  String? _selectedSession;
  DateTime _selectedDate = DateTime.now();

  // Sample services data - moved to a separate method
  List<Service> get services => _getServices();
  List<Service> _getServices() {
    return [
      Service(id: '1', name: 'General Consultation', maxSlotsPerSession: 15, doctorIds: ['1', '2']),
      Service(id: '2', name: 'Dental Services', maxSlotsPerSession: 8, doctorIds: ['3', '4']),
      Service(id: '3', name: 'Laboratory Tests', maxSlotsPerSession: 20, doctorIds: ['5', '6']),
      Service(id: '4', name: 'Pharmacy Services', maxSlotsPerSession: 25, doctorIds: ['7']),
      Service(id: '5', name: 'Maternity Services', maxSlotsPerSession: 10, doctorIds: ['8', '9']),
      Service(id: '6', name: 'Pediatric Care', maxSlotsPerSession: 12, doctorIds: ['10', '1']),
      Service(id: '7', name: 'Physiotherapy', maxSlotsPerSession: 6, doctorIds: ['2', '3']),
      Service(id: '8', name: 'Vaccination', maxSlotsPerSession: 30, doctorIds: ['4', '5']),
      Service(id: '9', name: 'X-Ray Services', maxSlotsPerSession: 15, doctorIds: ['6', '7']),
      Service(id: '10', name: 'Mental Health Services', maxSlotsPerSession: 8, doctorIds: ['8', '9']),
    ];
  }

  // Sample doctors data - moved to a separate method
  List<Doctor> get doctors => _getDoctors();
  List<Doctor> _getDoctors() {
    return [
      Doctor(id: '1', name: 'Dr. John Kama', specialization: 'General Practitioner'),
      Doctor(id: '2', name: 'Dr. Sarah Kanji', specialization: 'Pediatrician'),
      Doctor(id: '3', name: 'Dr. Michael Chien', specialization: 'Dentist'),
      Doctor(id: '4', name: 'Dr. Jane Munition', specialization: 'Gynecologist'),
      Doctor(id: '5', name: 'Dr. Peter proj', specialization: 'Laboratory Specialist'),
      Doctor(id: '6', name: 'Dr. Lucy Cambodia', specialization: 'Radiologist'),
      Doctor(id: '7', name: 'Dr. James Probiotic', specialization: 'Pharmacist'),
      Doctor(id: '8', name: 'Dr. Mary Neri', specialization: 'Obstetrician'),
      Doctor(id: '9', name: 'Dr. David monad', specialization: 'Psychiatrist'),
      Doctor(id: '10', name: 'Dr. Grace Iambus', specialization: 'Physiotherapist'),
    ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _countyController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => _showCart(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPatientInfoSection(),
                  const SizedBox(height: 20),
                  _buildServiceSelection(),
                  const SizedBox(height: 20),
                  if (_selectedService != null) _buildDoctorSelection(),
                  const SizedBox(height: 20),
                  if (_selectedDoctor != null) _buildDateTimeSelection(),
                  const SizedBox(height: 20),
                  _buildBookingButton(),
                ].animate(interval: const Duration(milliseconds: 100))
                    .fadeIn(duration: const Duration(milliseconds: 500))
                    .slideX(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfoSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patient Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your phone number';
                }
                if (!RegExp(r'^\d{10}$').hasMatch(value!)) {
                  return 'Please enter a valid 10-digit phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your age';
                      }
                      final age = int.tryParse(value!);
                      if (age == null || age < 0 || age > 150) {
                        return 'Please enter a valid age';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _idNumberController,
                    decoration: const InputDecoration(
                      labelText: 'ID Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.credit_card),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your ID number';
                      }
                      if (value!.length < 5) {
                        return 'ID number must be at least 5 characters';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _countyController,
              decoration: const InputDecoration(
                labelText: 'County',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your county';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSelection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Service',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_services),
              ),
              value: _selectedService,
              items: services.map((Service service) {
                return DropdownMenuItem(
                  value: service.id,
                  child: Text(service.name),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedService = value;
                  _selectedDoctor = null;
                  _selectedSession = null;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a service';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorSelection() {
    final Service selectedService = services.firstWhere((s) => s.id == _selectedService);
    final List<Doctor> availableDoctors = doctors
        .where((d) => selectedService.doctorIds.contains(d.id))
        .toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Doctor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              value: _selectedDoctor,
              items: availableDoctors.map((Doctor doctor) {
                return DropdownMenuItem(
                  value: doctor.id,
                  child: Text('${doctor.name} (${doctor.specialization})'),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedDoctor = value;
                  _selectedSession = null;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a doctor';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Date and Session',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('serviceId', isEqualTo: _selectedService)
                  .where('dateTime',
                  isGreaterThanOrEqualTo: DateTime(
                      _selectedDate.year, _selectedDate.month, _selectedDate.day))
                  .where('dateTime',
                  isLessThan: DateTime(
                      _selectedDate.year, _selectedDate.month, _selectedDate.day + 1))
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final Map<String, int> sessionCounts = {
                  'Morning (8:00 AM - 1:00 PM)': 0,
                  'Afternoon (2:00 PM - 4:00 PM)': 0,
                };

                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    String session = data['session'] as String;
                    sessionCounts[session] = (sessionCounts[session] ?? 0) + 1;
                  }
                }

                final Service service =
                services.firstWhere((s) => s.id == _selectedService);

                return Column(
                  children: sessionCounts.entries.map((entry) {
                    int availableSlots =
                        service.maxSlotsPerSession - entry.value;
                    bool isAvailable = availableSlots > 0;

                    return RadioListTile<String>(
                      title: Text(entry.key),
                      subtitle: Text(
                        'Available slots: $availableSlots',
                        style: TextStyle(
                          color: isAvailable ? Colors.green : Colors.red,
                        ),
                      ),
                      value: entry.key,
                      groupValue: _selectedSession,
                      onChanged: isAvailable
                          ? (String? value) {
                        setState(() {
                          _selectedSession = value;
                        });
                      }
                          : null,
                      activeColor: Colors.blue,
                      tileColor: isAvailable ? null : Colors.grey.shade200,
                    ).animate()
                        .fadeIn()
                        .scale();
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBookingButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: _selectedSession == null ? null : _bookAppointment,
      child: const Text(
        'Book Appointment',
        style: TextStyle(fontSize: 18),
      ),
    ).animate()
        .fadeIn()
        .scale();
  }

  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final String appointmentId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create a new appointment
      final appointment = Appointment(
        id: appointmentId,
        patientName: _nameController.text,
        phoneNumber: _phoneController.text,
        age: int.parse(_ageController.text),
        county: _countyController.text,
        idNumber: _idNumberController.text,
        serviceId: _selectedService!,
        doctorId: _selectedDoctor!,
        dateTime: _selectedDate,
        session: _selectedSession!,
      );

      // Add to Firestore
      await FirebaseFirestore.instance.collection('appointments').doc(appointmentId).set({
        'id': appointmentId,
        'patientName': appointment.patientName,
        'phoneNumber': appointment.phoneNumber,
        'age': appointment.age,
        'county': appointment.county,
        'idNumber': appointment.idNumber,
        'serviceId': appointment.serviceId,
        'doctorId': appointment.doctorId,
        'dateTime': appointment.dateTime,
        'session': appointment.session,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Correctly access the cart provider
      if (!mounted) return;
      final cartProvider = Provider.of<AppointmentCartProvider>(context, listen: false);
      cartProvider.addAppointment(appointment);

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Appointment booked successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            left: 20,
            right: 20,
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Clear form
      _clearForm();
    } catch (e) {
      debugPrint('Error booking appointment: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error booking appointment: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            left: 20,
            right: 20,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _ageController.clear();
    _countyController.clear();
    _idNumberController.clear();
    setState(() {
      _selectedService = null;
      _selectedDoctor = null;
      _selectedSession = null;
      _selectedDate = DateTime.now();
    });
  }

  void _showCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Consumer<AppointmentCartProvider>(
          builder: (context, provider, child) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Appointments Cart',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: provider.appointments.isEmpty
                        ? const Center(
                      child: Text('No appointments in cart'),
                    )
                        : ListView.builder(
                      itemCount: provider.appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = provider.appointments[index];
                        return _buildAppointmentCard(context, appointment, provider);
                      },
                    ),
                  ),
                  if (provider.appointments.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          provider.clearCart();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear Cart'),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

// Helper method to build appointment card
  Widget _buildAppointmentCard(
      BuildContext context,
      Appointment appointment,
      AppointmentCartProvider provider,
      ) {
    final service = services.firstWhere((s) => s.id == appointment.serviceId);
    final doctor = doctors.firstWhere((d) => d.id == appointment.doctorId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(service.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doctor.name),
            Text('Date: ${DateFormat('yyyy-MM-dd').format(appointment.dateTime)}'),
            Text('Session: ${appointment.session}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            provider.removeAppointment(appointment.id);
            _deleteAppointment(appointment.id);
          },
        ),
      ),
    );
  }
  void _setReminder(Appointment appointment) async {
    // Implement reminder functionality here
    // This could use local notifications or any other reminder system
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reminder set for your appointment'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteAppointment(String appointmentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment cancelled successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling appointment: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

