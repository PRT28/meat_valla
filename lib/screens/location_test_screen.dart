import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import '../utils/app_colors.dart';

class LocationTestScreen extends StatefulWidget {
  const LocationTestScreen({super.key});

  @override
  State<LocationTestScreen> createState() => _LocationTestScreenState();
}

class _LocationTestScreenState extends State<LocationTestScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  
  List<PlaceSearchResult> _searchResults = [];
  AddressInfo? _reverseGeocodeResult;
  bool _isSearching = false;
  bool _isReverseGeocoding = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Service Test (Photon)'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Test Section
            const Text(
              'Search Test',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for places...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: _searchPlaces,
            ),
            
            const SizedBox(height: 16),
            
            // Search Results
            if (_searchResults.isNotEmpty) ...[
              const Text(
                'Search Results:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on, size: 16),
                      title: Text(
                        result.displayName,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        '${result.location.latitude.toStringAsFixed(4)}, ${result.location.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        _latController.text = result.location.latitude.toString();
                        _lngController.text = result.location.longitude.toString();
                        _reverseGeocode();
                      },
                    );
                  },
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Reverse Geocoding Test Section
            const Text(
              'Reverse Geocoding Test',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _lngController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: _isReverseGeocoding ? null : _reverseGeocode,
              child: _isReverseGeocoding
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Get Address'),
            ),
            
            const SizedBox(height: 16),
            
            // Reverse Geocoding Result
            if (_reverseGeocodeResult != null) ...[
              const Text(
                'Address Result:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Display Name: ${_reverseGeocodeResult!.displayName}'),
                    Text('House Number: ${_reverseGeocodeResult!.houseNumber}'),
                    Text('Road: ${_reverseGeocodeResult!.road}'),
                    Text('Suburb: ${_reverseGeocodeResult!.suburb}'),
                    Text('City: ${_reverseGeocodeResult!.city}'),
                    Text('State: ${_reverseGeocodeResult!.state}'),
                    Text('Postcode: ${_reverseGeocodeResult!.postcode}'),
                    Text('Country: ${_reverseGeocodeResult!.country}'),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Quick Test Buttons
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _latController.text = '28.6139';
                    _lngController.text = '77.2090';
                    _reverseGeocode();
                  },
                  child: const Text('Test Delhi'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _latController.text = '19.0760';
                    _lngController.text = '72.8777';
                    _reverseGeocode();
                  },
                  child: const Text('Test Mumbai'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _latController.text = '12.9716';
                    _lngController.text = '77.5946';
                    _reverseGeocode();
                  },
                  child: const Text('Test Bangalore'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await LocationService.searchPlaces(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    }
  }

  Future<void> _reverseGeocode() async {
    final latText = _latController.text.trim();
    final lngText = _lngController.text.trim();
    
    if (latText.isEmpty || lngText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both latitude and longitude')),
      );
      return;
    }

    final lat = double.tryParse(latText);
    final lng = double.tryParse(lngText);
    
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers')),
      );
      return;
    }

    setState(() {
      _isReverseGeocoding = true;
    });

    try {
      final result = await LocationService.reverseGeocode(LatLng(lat, lng));
      setState(() {
        _reverseGeocodeResult = result;
        _isReverseGeocoding = false;
      });
    } catch (e) {
      setState(() {
        _reverseGeocodeResult = null;
        _isReverseGeocoding = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reverse geocoding failed: $e')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }
}
