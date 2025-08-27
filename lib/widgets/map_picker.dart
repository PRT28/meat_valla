import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapPicker extends StatefulWidget {
  const MapPicker({super.key});

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  LatLng? _selectedLatLng;

  // Example: Your store location
  final LatLng serviceCenter = LatLng(28.6139, 77.2090); // New Delhi
  final double serviceRadiusKm = 35;

  final mapController = MapController();

  Future<bool> _isWithinServiceArea(LatLng userLocation) async {
    final distance = Geolocator.distanceBetween(
      serviceCenter.latitude,
      serviceCenter.longitude,
      userLocation.latitude,
      userLocation.longitude,
    );
    return distance / 1000 <= serviceRadiusKm;
  }

  void _onMapTap(LatLng latLng) async {
    bool serviceable = await _isWithinServiceArea(latLng);

    setState(() {
      _selectedLatLng = latLng;
    });

    if (!serviceable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🚫 This area is not serviceable (35km limit)"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Delivery available here"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Delivery Location")),
      body: SizedBox.expand(
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: serviceCenter,
            initialZoom: 11,
            minZoom: 3,
            maxZoom: 18,
            onTap: (tapPosition, point) => _onMapTap(point),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
              subdomains: ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: serviceCenter,
                  width: 60,
                  height: 60,
                  child: const Icon(Icons.store, color: Colors.blue, size: 40),
                ),
                if (_selectedLatLng != null)
                  Marker(
                    point: _selectedLatLng!,
                    width: 60,
                    height: 60,
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                  ),
              ],
            ),
            CircleLayer(
              circles: [
                CircleMarker(
                  point: serviceCenter,
                  color: Colors.white.withOpacity(0.1),
                  borderStrokeWidth: 2,
                  borderColor: Colors.blue,
                  radius: serviceRadiusKm * 1000,
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedLatLng != null
          ? FloatingActionButton.extended(
        onPressed: () async {
          bool serviceable = await _isWithinServiceArea(_selectedLatLng!);
          if (serviceable) {
            Navigator.pop(context, _selectedLatLng);
          }
        },
        label: const Text("Confirm Location"),
        icon: const Icon(Icons.check),
      )
          : null,
    );
  }
}
