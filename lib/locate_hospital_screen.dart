import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'locate_hospital_screen.g.dart';


@JsonSerializable()
class LatLng {
  LatLng({
    required this.lat,
    required this.lng,
  });

  factory LatLng.fromJson(Map<String, dynamic> json) => _$LatLngFromJson(json);
  Map<String, dynamic> toJson() => _$LatLngToJson(this);

  final double lat;
  final double lng;
}

@JsonSerializable()
class Region {
  Region({
    required this.coords,
    required this.id,
    required this.name,
    required this.zoom,
  });

  factory Region.fromJson(Map<String, dynamic> json) => _$RegionFromJson(json);
  Map<String, dynamic> toJson() => _$RegionToJson(this);

  final LatLng coords;
  final String id;
  final String name;
  final double zoom;
}

@JsonSerializable()
class Hospital {
  Hospital({
    required this.address,
    required this.id,
    required this.image,
    required this.lat,
    required this.lng,
    required this.name,
    required this.phone,
    required this.region,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) => _$HospitalFromJson(json);
  Map<String, dynamic> toJson() => _$HospitalToJson(this);

  final String address;
  final String id;
  final String image;
  final double lat;
  final double lng;
  final String name;
  final String phone;
  final String region;
}

@JsonSerializable()
class Locations {
  Locations({
    required this.hospitals,
    required this.regions,
  });

  factory Locations.fromJson(Map<String, dynamic> json) =>
      _$LocationsFromJson(json);
  Map<String, dynamic> toJson() => _$LocationsToJson(this);

  final List<Hospital> hospitals;
  final List<Region> regions;
}

Future<Locations> getHospitalLocations() async {
  const hospitalLocationsURL = 'https://example.com/static/data/hospitals.json'; // Update with your API URL

  // Retrieve the hospital locations
  try {
    final response = await http.get(Uri.parse(hospitalLocationsURL));
    if (response.statusCode == 200) {
      return Locations.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }

  // Fallback for when the above HTTP request fails.
  return Locations.fromJson(
    json.decode(
      await rootBundle.loadString('assets/hospitals.json'),
    ) as Map<String, dynamic>,
  );
}

// Create the Locate Hospital Screen
class LocateHospitalScreen extends StatelessWidget {
  const LocateHospitalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locate Hospital'),
      ),
      body: FutureBuilder<Locations>(
        future: getHospitalLocations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading hospital data'));
          } else if (!snapshot.hasData || snapshot.data!.hospitals.isEmpty) {
            return const Center(child: Text('No hospitals found'));
          } else {
            final hospitals = snapshot.data!.hospitals;
            return ListView.builder(
              itemCount: hospitals.length,
              itemBuilder: (context, index) {
                final hospital = hospitals[index];
                return ListTile(
                  title: Text(hospital.name),
                  subtitle: Text(hospital.address),
                  trailing: IconButton(
                    icon: const Icon(Icons.call),
                    onPressed: () {
                      // Call hospital's phone number
                    },
                  ),
                  onTap: () {
                    // Navigate to detailed hospital page or map view
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
