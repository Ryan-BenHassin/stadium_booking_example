import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  MapboxMap? mapboxMap;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapbox Example')),
      body: MapWidget(
        onMapCreated: (MapboxMap mapboxMap) {
          this.mapboxMap = mapboxMap;
          mapboxMap.location.updateSettings(
            LocationComponentSettings(
              enabled: true,
              pulsingEnabled: true,
              
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToMyLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
