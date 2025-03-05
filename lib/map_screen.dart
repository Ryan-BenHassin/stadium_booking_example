import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'models/complex.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;

  // Add static list of complexes
  final List<Complex> complexes = [
    Complex(
      name: 'Complex A',
      latitude: 36.809019,
      longitude: 10.149182,
      description: 'San Francisco Complex',
    ),
    Complex(
      name: 'Sports Complex',
      latitude: 31.9520,
      longitude: 35.9120,
      description: 'Athletic Facilities',
    ),
    // Add more complexes as needed
  ];

  @override
  void initState() {
    super.initState();
    
    // _requestLocationPermission();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _goToMyLocation();
    // });
    
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
      print("\n\n My current position : ${position.latitude} \n\n");
      
      await mapboxMap?.easeTo(
        CameraOptions(
          center: Point(coordinates: Position(position.longitude, position.latitude)),
          zoom: 14.0,
        ),
        MapAnimationOptions(duration: 1000)
      );
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> addComplexesToMap() async {
    pointAnnotationManager ??= await mapboxMap?.annotations.createPointAnnotationManager();
    pointAnnotationManager?.deleteAll();

    for (var complex in complexes) {
      final circleManager = await mapboxMap?.annotations.createCircleAnnotationManager();
      await circleManager?.create(CircleAnnotationOptions(
        geometry: Point(coordinates: Position(complex.longitude, complex.latitude)),
        circleColor: Colors.red.value,
        circleRadius: 8.0,
      ));

      // Add text annotation for the name
      final textManager = await mapboxMap?.annotations.createPointAnnotationManager();
      await textManager?.create(PointAnnotationOptions(
        geometry: Point(coordinates: Position(complex.longitude, complex.latitude)),
        textField: complex.name,
        textOffset: [0.0, 1.0],
        textColor: Colors.black.value,
        textSize: 12.0,
      ));
    }

    // Updated click listener implementation
    pointAnnotationManager?.addOnPointAnnotationClickListener(
      _ComplexClickListener(
        complexes: complexes,
        context: context,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Map')),
      body: MapWidget(
        onMapCreated: (MapboxMap mapboxMap) {
          this.mapboxMap = mapboxMap;
          mapboxMap.location.updateSettings(
            LocationComponentSettings(
              enabled: true,
              pulsingEnabled: true,
              
            ),
          );
          addComplexesToMap(); // Add markers when map is created
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToMyLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

// Add this class at the bottom of the file
class _ComplexClickListener extends OnPointAnnotationClickListener {
  final List<Complex> complexes;
  final BuildContext context;

  _ComplexClickListener({
    required this.complexes,
    required this.context,
  });

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    final complex = complexes.firstWhere(
      (c) => c.longitude == annotation.geometry.coordinates[0] && 
             c.latitude == annotation.geometry.coordinates[1],
      orElse: () => complexes.first, // Fallback if not found
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(complex.name),
        content: Text(complex.description ?? 'No description available'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
