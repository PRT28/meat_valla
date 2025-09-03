import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationService {
  static const String _photonBaseUrl = 'https://photon.komoot.io';

  /// Check and request location permissions
  static Future<bool> requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  /// Get current location using GPS
  static Future<LatLng?> getCurrentLocation() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Reverse geocode coordinates to address using multiple services
  static Future<AddressInfo?> reverseGeocode(LatLng location) async {
    // Try Photon reverse geocoding first (more reliable and doesn't need platform setup)
    try {
      final url = Uri.parse(
        '$_photonBaseUrl/reverse?lat=${location.latitude}&lon=${location.longitude}&lang=en'
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'MeatValla/1.0 (Flutter App)',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['features'] != null && data['features'].isNotEmpty) {
          final feature = data['features'][0];
          return AddressInfo.fromPhoton(feature);
        }
      } else {
        print('Photon HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Photon geocoding failed: $e');
    }



    // Last fallback - create basic address info from coordinates
    return AddressInfo(
      displayName: 'Location: ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
      houseNumber: '',
      road: 'Selected Location',
      suburb: '',
      city: 'Unknown City',
      state: 'Unknown State',
      postcode: '',
      country: 'India',
    );
  }

  /// Search for places using multiple strategies
  static Future<List<PlaceSearchResult>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    List<PlaceSearchResult> results = [];

    // Try Photon search with India bias
    try {
      final url = Uri.parse(
        '$_photonBaseUrl/api?q=${Uri.encodeComponent(query)}&limit=8&lang=en&bbox=68.1766451354,7.96553477623,97.4025614766,35.4940095078'
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'MeatValla/1.0 (Flutter App)',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['features'] != null) {
          final List<dynamic> features = data['features'];
          results = features.map((feature) => PlaceSearchResult.fromPhoton(feature)).toList();

          if (results.isNotEmpty) {
            return results;
          }
        }
      } else {
        print('Photon search HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Photon search failed: $e');
    }

    // Fallback: Try searching without bbox restriction
    try {
      final url = Uri.parse(
        '$_photonBaseUrl/api?q=${Uri.encodeComponent(query)}&limit=5&lang=en'
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'MeatValla/1.0 (Flutter App)',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['features'] != null) {
          final List<dynamic> features = data['features'];
          results = features.map((feature) => PlaceSearchResult.fromPhoton(feature)).toList();
        }
      }
    } catch (e) {
      print('Fallback search failed: $e');
    }

    // If still no results, provide some common Indian cities as suggestions
    if (results.isEmpty && query.length >= 2) {
      results = _getCommonCitySuggestions(query);
    }

    return results;
  }

  /// Get common Indian city suggestions when search fails
  static List<PlaceSearchResult> _getCommonCitySuggestions(String query) {
    final commonCities = {
      'Delhi': LatLng(28.6139, 77.2090),
      'Mumbai': LatLng(19.0760, 72.8777),
      'Bangalore': LatLng(12.9716, 77.5946),
      'Hyderabad': LatLng(17.3850, 78.4867),
      'Chennai': LatLng(13.0827, 80.2707),
      'Kolkata': LatLng(22.5726, 88.3639),
      'Pune': LatLng(18.5204, 73.8567),
      'Ahmedabad': LatLng(23.0225, 72.5714),
      'Jaipur': LatLng(26.9124, 75.7873),
      'Surat': LatLng(21.1702, 72.8311),
      'Lucknow': LatLng(26.8467, 80.9462),
      'Kanpur': LatLng(26.4499, 80.3319),
      'Nagpur': LatLng(21.1458, 79.0882),
      'Indore': LatLng(22.7196, 75.8577),
      'Thane': LatLng(19.2183, 72.9781),
      'Bhopal': LatLng(23.2599, 77.4126),
      'Visakhapatnam': LatLng(17.6868, 83.2185),
      'Pimpri': LatLng(18.6298, 73.7997),
      'Patna': LatLng(25.5941, 85.1376),
      'Vadodara': LatLng(22.3072, 73.1812),
      'Ghaziabad': LatLng(28.6692, 77.4538),
      'Ludhiana': LatLng(30.9010, 75.8573),
      'Agra': LatLng(27.1767, 78.0081),
      'Nashik': LatLng(19.9975, 73.7898),
      'Faridabad': LatLng(28.4089, 77.3178),
      'Meerut': LatLng(28.9845, 77.7064),
      'Rajkot': LatLng(22.3039, 70.8022),
      'Kalyan': LatLng(19.2437, 73.1355),
      'Vasai': LatLng(19.4911, 72.8054),
      'Varanasi': LatLng(25.3176, 82.9739),
      'Srinagar': LatLng(34.0837, 74.7973),
      'Aurangabad': LatLng(19.8762, 75.3433),
      'Dhanbad': LatLng(23.7957, 86.4304),
      'Amritsar': LatLng(31.6340, 74.8723),
      'Navi Mumbai': LatLng(19.0330, 73.0297),
      'Allahabad': LatLng(25.4358, 81.8463),
      'Ranchi': LatLng(23.3441, 85.3096),
      'Howrah': LatLng(22.5958, 88.2636),
      'Coimbatore': LatLng(11.0168, 76.9558),
      'Jabalpur': LatLng(23.1815, 79.9864),
      'Gwalior': LatLng(26.2183, 78.1828),
      'Vijayawada': LatLng(16.5062, 80.6480),
      'Jodhpur': LatLng(26.2389, 73.0243),
      'Madurai': LatLng(9.9252, 78.1198),
      'Raipur': LatLng(21.2514, 81.6296),
      'Kota': LatLng(25.2138, 75.8648),
      'Guwahati': LatLng(26.1445, 91.7362),
      'Chandigarh': LatLng(30.7333, 76.7794),
      'Solapur': LatLng(17.6599, 75.9064),
      'Hubli': LatLng(15.3647, 75.1240),
      'Bareilly': LatLng(28.3670, 79.4304),
      'Moradabad': LatLng(28.8386, 78.7733),
      'Mysore': LatLng(12.2958, 76.6394),
      'Gurgaon': LatLng(28.4595, 77.0266),
      'Aligarh': LatLng(27.8974, 78.0880),
      'Jalandhar': LatLng(31.3260, 75.5762),
      'Tiruchirappalli': LatLng(10.7905, 78.7047),
      'Bhubaneswar': LatLng(20.2961, 85.8245),
      'Salem': LatLng(11.6643, 78.1460),
      'Mira': LatLng(19.2952, 72.8694),
      'Warangal': LatLng(17.9689, 79.5941),
      'Guntur': LatLng(16.3067, 80.4365),
      'Bhiwandi': LatLng(19.3002, 73.0635),
      'Saharanpur': LatLng(29.9680, 77.5552),
      'Gorakhpur': LatLng(26.7606, 83.3732),
      'Bikaner': LatLng(28.0229, 73.3119),
      'Amravati': LatLng(20.9374, 77.7796),
      'Noida': LatLng(28.5355, 77.3910),
      'Jamshedpur': LatLng(22.8046, 86.2029),
      'Bhilai': LatLng(21.1938, 81.3509),
      'Cuttack': LatLng(20.4625, 85.8828),
      'Firozabad': LatLng(27.1592, 78.3957),
      'Kochi': LatLng(9.9312, 76.2673),
      'Bhavnagar': LatLng(21.7645, 72.1519),
      'Dehradun': LatLng(30.3165, 78.0322),
      'Durgapur': LatLng(23.4800, 87.3119),
      'Asansol': LatLng(23.6739, 86.9524),
      'Nanded': LatLng(19.1383, 77.2975),
      'Kolhapur': LatLng(16.7050, 74.2433),
      'Ajmer': LatLng(26.4499, 74.6399),
      'Akola': LatLng(20.7002, 77.0082),
      'Gulbarga': LatLng(17.3297, 76.8343),
      'Jamnagar': LatLng(22.4707, 70.0577),
      'Ujjain': LatLng(23.1765, 75.7885),
      'Loni': LatLng(28.7333, 77.2833),
      'Siliguri': LatLng(26.7271, 88.3953),
      'Jhansi': LatLng(25.4484, 78.5685),
      'Ulhasnagar': LatLng(19.2215, 73.1645),
      'Nellore': LatLng(14.4426, 79.9865),
      'Jammu': LatLng(32.7266, 74.8570),
      'Sangli': LatLng(16.8524, 74.5815),
      'Belgaum': LatLng(15.8497, 74.4977),
      'Mangalore': LatLng(12.9141, 74.8560),
      'Ambattur': LatLng(13.1143, 80.1548),
      'Tirunelveli': LatLng(8.7139, 77.7567),
      'Malegaon': LatLng(20.5579, 74.5287),
      'Gaya': LatLng(24.7914, 85.0002),
      'Jalgaon': LatLng(21.0077, 75.5626),
      'Udaipur': LatLng(24.5854, 73.7125),
      'Maheshtala': LatLng(22.4986, 88.2475),
    };

    final queryLower = query.toLowerCase();
    final suggestions = <PlaceSearchResult>[];

    for (final entry in commonCities.entries) {
      if (entry.key.toLowerCase().contains(queryLower)) {
        suggestions.add(PlaceSearchResult(
          displayName: '${entry.key}, India',
          location: entry.value,
          type: 'city',
        ));
      }
    }

    return suggestions.take(5).toList();
  }



  /// Calculate distance between two points
  static double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }
}

class AddressInfo {
  final String displayName;
  final String houseNumber;
  final String road;
  final String suburb;
  final String city;
  final String state;
  final String postcode;
  final String country;

  AddressInfo({
    required this.displayName,
    required this.houseNumber,
    required this.road,
    required this.suburb,
    required this.city,
    required this.state,
    required this.postcode,
    required this.country,
  });

  factory AddressInfo.fromPhoton(Map<String, dynamic> feature) {
    final properties = feature['properties'] ?? {};

    // Build display name from available components
    List<String> nameParts = [];
    if (properties['name'] != null && properties['name'].toString().isNotEmpty) {
      nameParts.add(properties['name'].toString());
    }
    if (properties['street'] != null && properties['street'].toString().isNotEmpty) {
      nameParts.add(properties['street'].toString());
    }
    if (properties['city'] != null && properties['city'].toString().isNotEmpty) {
      nameParts.add(properties['city'].toString());
    }
    if (properties['state'] != null && properties['state'].toString().isNotEmpty) {
      nameParts.add(properties['state'].toString());
    }
    if (properties['country'] != null && properties['country'].toString().isNotEmpty) {
      nameParts.add(properties['country'].toString());
    }

    return AddressInfo(
      displayName: nameParts.isNotEmpty ? nameParts.join(', ') : 'Unknown Location',
      houseNumber: properties['housenumber']?.toString() ?? '',
      road: properties['street']?.toString() ?? '',
      suburb: properties['district']?.toString() ?? properties['suburb']?.toString() ?? '',
      city: properties['city']?.toString() ?? properties['town']?.toString() ?? properties['village']?.toString() ?? '',
      state: properties['state']?.toString() ?? '',
      postcode: properties['postcode']?.toString() ?? '',
      country: properties['country']?.toString() ?? 'India',
    );
  }

  // Keep the old method for backward compatibility
  factory AddressInfo.fromNominatim(Map<String, dynamic> data) {
    final address = data['address'] ?? {};
    return AddressInfo(
      displayName: data['display_name'] ?? '',
      houseNumber: address['house_number'] ?? '',
      road: address['road'] ?? '',
      suburb: address['suburb'] ?? address['neighbourhood'] ?? '',
      city: address['city'] ?? address['town'] ?? address['village'] ?? '',
      state: address['state'] ?? '',
      postcode: address['postcode'] ?? '',
      country: address['country'] ?? '',
    );
  }

  String get formattedAddress {
    List<String> parts = [];
    if (houseNumber.isNotEmpty) parts.add(houseNumber);
    if (road.isNotEmpty) parts.add(road);
    if (suburb.isNotEmpty) parts.add(suburb);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (postcode.isNotEmpty) parts.add(postcode);
    return parts.join(', ');
  }
}

class PlaceSearchResult {
  final String displayName;
  final LatLng location;
  final String type;

  PlaceSearchResult({
    required this.displayName,
    required this.location,
    required this.type,
  });

  factory PlaceSearchResult.fromPhoton(Map<String, dynamic> feature) {
    final properties = feature['properties'] ?? {};
    final geometry = feature['geometry'] ?? {};
    final coordinates = geometry['coordinates'] ?? [];

    // Build display name from available components
    List<String> nameParts = [];
    if (properties['name'] != null && properties['name'].toString().isNotEmpty) {
      nameParts.add(properties['name'].toString());
    }
    if (properties['street'] != null && properties['street'].toString().isNotEmpty &&
        properties['street'] != properties['name']) {
      nameParts.add(properties['street'].toString());
    }
    if (properties['city'] != null && properties['city'].toString().isNotEmpty) {
      nameParts.add(properties['city'].toString());
    }
    if (properties['state'] != null && properties['state'].toString().isNotEmpty) {
      nameParts.add(properties['state'].toString());
    }

    return PlaceSearchResult(
      displayName: nameParts.isNotEmpty ? nameParts.join(', ') : 'Unknown Location',
      location: LatLng(
        coordinates.length > 1 ? coordinates[1].toDouble() : 0.0,
        coordinates.isNotEmpty ? coordinates[0].toDouble() : 0.0,
      ),
      type: properties['osm_key']?.toString() ?? properties['type']?.toString() ?? 'place',
    );
  }

  // Keep the old method for backward compatibility
  factory PlaceSearchResult.fromNominatim(Map<String, dynamic> data) {
    return PlaceSearchResult(
      displayName: data['display_name'] ?? '',
      location: LatLng(
        double.parse(data['lat'].toString()),
        double.parse(data['lon'].toString()),
      ),
      type: data['type'] ?? '',
    );
  }
}
