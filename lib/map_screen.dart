import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:latlong2/latlong.dart';
import 'models/complex.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController mapController = MapController();
  LatLng? currentLocation;

  // Add static list of complexes
  final List<Complex> complexes = [
    Complex(
      name: 'Complex A',
      longitude: 36.809019,
      latitude: 10.149182,
      description: 'San Francisco Complex',
    ),
    Complex(
      name: 'Complex B',
      latitude: 34.0522,
      longitude: -118.2437,
      description: 'Los Angeles Complex',
    ),
    // Add more complexes as needed
  ];

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _goToMyLocation();
    });
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await geolocator.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    geolocator.LocationPermission permission = await geolocator.Geolocator.checkPermission();
    if (permission == geolocator.LocationPermission.denied) {
      permission = await geolocator.Geolocator.requestPermission();
      if (permission == geolocator.LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
  }

  Future<void> _goToMyLocation() async {
    try {
      final geolocator.Position position = await geolocator.Geolocator.getCurrentPosition();
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
      mapController.move(currentLocation!, 14);
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complexes Map')),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: LatLng(0, 0),
          zoom: 2,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
            tileProvider: NetworkTileProvider(),
            maxZoom: 19,
            keepBuffer: 5,
          ),
          MarkerLayer(
            markers: [
              if (currentLocation != null)
                Marker(
                  point: currentLocation!,
                  width: 80,
                  height: 80,
                  builder: (context) => Icon(Icons.my_location_rounded, color: Colors.blue, size: 40),
                ),
              // Add markers for complexes
              ...complexes.map(
                (complex) => Marker(
                  point: LatLng(complex.latitude, complex.longitude),
                  width: 80,
                  height: 80,
                  builder: (context) => Tooltip(
                    message: '${complex.name}\n${complex.description ?? ""}',
                    child: Icon(Icons.location_on_sharp, color: Colors.red, size: 50),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToMyLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
