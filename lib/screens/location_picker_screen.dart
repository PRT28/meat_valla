import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import '../services/delivery_service.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerScreen({
    super.key,
    this.initialLocation,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  AddressInfo? _addressInfo;
  ServiceabilityResult? _serviceabilityResult;
  bool _isLoading = false;
  bool _isGettingCurrentLocation = false;
  bool _isSearching = false;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  List<PlaceSearchResult> _searchResults = [];
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation ?? LatLng(28.6139, 77.2090); // Default to Delhi
    _loadAddressInfo();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAddressInfo() async {
    if (_selectedLocation == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get address info and check serviceability
      final addressInfo = await LocationService.reverseGeocode(_selectedLocation!);
      final serviceabilityResult = DeliveryService.checkServiceability(_selectedLocation!);

      setState(() {
        _addressInfo = addressInfo;
        _serviceabilityResult = serviceabilityResult;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to get address for this location. Please try a different location or check your internet connection.';
        // Still show basic location info
        _addressInfo = AddressInfo(
          displayName: 'Selected Location',
          houseNumber: '',
          road: '',
          suburb: '',
          city: 'Unknown',
          state: 'Unknown',
          postcode: '',
          country: 'India',
        );
        _serviceabilityResult = DeliveryService.checkServiceability(_selectedLocation!);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingCurrentLocation = true;
    });

    try {
      final location = await LocationService.getCurrentLocation();
      if (location != null) {
        setState(() {
          _selectedLocation = location;
        });
        _mapController.move(location, 16.0);
        await _loadAddressInfo();
      } else {
        _showLocationPermissionDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isGettingCurrentLocation = false;
      });
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Please enable location services and grant location permission to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
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
        _showSearchResults = true;
        _isSearching = false;
      });
    } catch (e) {
      print('Error searching places: $e');
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
        _isSearching = false;
      });

      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Search failed. Please check your internet connection and try again.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _selectSearchResult(PlaceSearchResult result) {
    setState(() {
      _selectedLocation = result.location;
      _showSearchResults = false;
      _searchController.clear();
    });
    _mapController.move(result.location, 16.0);
    _loadAddressInfo();
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
    _loadAddressInfo();
  }

  void _confirmLocation() {
    if (_selectedLocation != null && _addressInfo != null) {
      // Check if location is serviceable before allowing confirmation
      if (_serviceabilityResult?.isServiceable == true) {
        Navigator.of(context).pop({
          'location': _selectedLocation,
          'addressInfo': _addressInfo,
          'serviceabilityResult': _serviceabilityResult,
        });
      } else {
        // Show error dialog for non-serviceable area
        _showNonServiceableDialog();
      }
    }
  }

  void _showNonServiceableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.red),
            SizedBox(width: 8),
            Text('Area Not Serviceable'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_serviceabilityResult?.message ?? 'This area is not serviceable.'),
            const SizedBox(height: 16),
            const Text(
              'We currently deliver within 50km radius from our warehouses. Please select a different location.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation ?? LatLng(28.6139, 77.2090),
              initialZoom: 16.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.meatvalla.app',
              ),
              // Warehouse markers
              MarkerLayer(
                markers: [
                  // Warehouse locations
                  ...DeliveryService.warehouses.map((warehouse) => Marker(
                    point: warehouse.location,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.warehouse,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  )),
                  // Selected location marker
                  if (_selectedLocation != null)
                    Marker(
                      point: _selectedLocation!,
                      child: Icon(
                        Icons.location_pin,
                        color: _serviceabilityResult?.isServiceable == true
                            ? AppColors.primary
                            : Colors.red,
                        size: 40,
                      ),
                    ),
                ],
              ),

              // Service area circles (optional - can be toggled)
              CircleLayer(
                circles: DeliveryService.warehouses.map((warehouse) => CircleMarker(
                  point: warehouse.location,
                  color: Colors.blue.withOpacity(0.1),
                  borderStrokeWidth: 1,
                  borderColor: Colors.blue.withOpacity(0.3),
                  radius: warehouse.serviceRadiusKm * 1000, // Convert km to meters
                )).toList(),
              ),
            ],
          ),

          // Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for area, street name...',
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
                          : _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchPlaces('');
                                  },
                                )
                              : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: _searchPlaces,
                  ),
                ),

                // Search Results
                if (_showSearchResults)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _searchResults.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final result = _searchResults[index];
                              return ListTile(
                                leading: const Icon(Icons.location_on, color: AppColors.primary),
                                title: Text(
                                  result.displayName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  result.type,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                onTap: () => _selectSearchResult(result),
                              );
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  color: AppColors.textSecondary,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'No results found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Try searching for a city, area, or landmark',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary.withOpacity(0.7),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                  ),
              ],
            ),
          ),

          // Current Location Button
          Positioned(
            top: 100,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              onPressed: _isGettingCurrentLocation ? null : _getCurrentLocation,
              child: _isGettingCurrentLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),

          // Bottom Sheet with Address Info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Address Info
                    if (_isLoading)
                      const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text(
                              'Getting address information...',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_addressInfo != null) ...[
                      // Show error message if there was an issue getting address
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning, color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Row(
                        children: [
                          Icon(
                            _serviceabilityResult?.isServiceable == true
                                ? Icons.location_pin
                                : Icons.location_off,
                            color: _serviceabilityResult?.isServiceable == true
                                ? AppColors.primary
                                : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _addressInfo!.city.isNotEmpty
                                      ? _addressInfo!.city
                                      : 'Selected Location',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _addressInfo!.formattedAddress,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Serviceability Status
                      if (_serviceabilityResult != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _serviceabilityResult!.isServiceable
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _serviceabilityResult!.isServiceable
                                  ? Colors.green
                                  : Colors.red,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _serviceabilityResult!.isServiceable
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: _serviceabilityResult!.isServiceable
                                    ? Colors.green
                                    : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _serviceabilityResult!.isServiceable
                                          ? 'Delivery Available'
                                          : 'Not Serviceable',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _serviceabilityResult!.isServiceable
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    if (_serviceabilityResult!.isServiceable && _serviceabilityResult!.nearestWarehouse != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'From ${_serviceabilityResult!.nearestWarehouse!.name} • ${_serviceabilityResult!.distanceKm.toStringAsFixed(1)}km away',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        'Est. delivery: ${DeliveryService.getEstimatedDeliveryTime(_serviceabilityResult!.distanceKm)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ] else if (!_serviceabilityResult!.isServiceable) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        _serviceabilityResult!.message,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],

                      // Confirm Button
                      CustomButton(
                        onPressed: _serviceabilityResult?.isServiceable == true
                            ? _confirmLocation
                            : null,
                        backgroundColor: _serviceabilityResult?.isServiceable == true
                            ? AppColors.primary
                            : Colors.grey,
                        child: Text(
                          _serviceabilityResult?.isServiceable == true
                              ? 'Confirm Location'
                              : 'Area Not Serviceable',
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Unable to get address for this location',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
