import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class DeliveryService {
  // Hardcoded warehouse locations (you can modify these as needed)
  static const List<WarehouseLocation> warehouses = [
    WarehouseLocation(
      id: 'warehouse_delhi',
      name: 'Delhi Warehouse',
      location: LatLng(28.6139, 77.2090), // New Delhi
      serviceRadiusKm: 50.0,
    ),
    WarehouseLocation(
      id: 'warehouse_mumbai',
      name: 'Mumbai Warehouse',
      location: LatLng(19.0760, 72.8777), // Mumbai
      serviceRadiusKm: 50.0,
    ),
    WarehouseLocation(
      id: 'warehouse_bangalore',
      name: 'Bangalore Warehouse',
      location: LatLng(12.9716, 77.5946), // Bangalore
      serviceRadiusKm: 50.0,
    ),
    WarehouseLocation(
      id: 'warehouse_hyderabad',
      name: 'Hyderabad Warehouse',
      location: LatLng(17.3850, 78.4867), // Hyderabad
      serviceRadiusKm: 50.0,
    ),
    WarehouseLocation(
      id: 'warehouse_chennai',
      name: 'Chennai Warehouse',
      location: LatLng(13.0827, 80.2707), // Chennai
      serviceRadiusKm: 50.0,
    ),
    WarehouseLocation(
      id: 'warehouse_kolkata',
      name: 'Kolkata Warehouse',
      location: LatLng(22.5726, 88.3639), // Kolkata
      serviceRadiusKm: 50.0,
    ),
  ];

  /// Check if a location is serviceable by any warehouse
  static ServiceabilityResult checkServiceability(LatLng userLocation) {
    WarehouseLocation? nearestWarehouse;
    double nearestDistance = double.infinity;

    for (final warehouse in warehouses) {
      final distance = _calculateDistance(userLocation, warehouse.location);
      
      if (distance <= warehouse.serviceRadiusKm) {
        // Location is serviceable by this warehouse
        return ServiceabilityResult(
          isServiceable: true,
          nearestWarehouse: warehouse,
          distanceKm: distance,
          message: 'Delivery available from ${warehouse.name}',
        );
      }

      // Track nearest warehouse for better error messaging
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestWarehouse = warehouse;
      }
    }

    // No warehouse can service this location
    return ServiceabilityResult(
      isServiceable: false,
      nearestWarehouse: nearestWarehouse,
      distanceKm: nearestDistance,
      message: nearestWarehouse != null
          ? 'Sorry, this area is not serviceable. Nearest warehouse is ${nearestDistance.toStringAsFixed(1)}km away in ${nearestWarehouse.name}. We deliver within 50km radius.'
          : 'Sorry, this area is not serviceable.',
    );
  }

  /// Get all warehouses within a certain distance
  static List<WarehouseDistance> getNearbyWarehouses(LatLng userLocation, {double maxDistanceKm = 100.0}) {
    final List<WarehouseDistance> nearbyWarehouses = [];

    for (final warehouse in warehouses) {
      final distance = _calculateDistance(userLocation, warehouse.location);
      if (distance <= maxDistanceKm) {
        nearbyWarehouses.add(WarehouseDistance(
          warehouse: warehouse,
          distanceKm: distance,
        ));
      }
    }

    // Sort by distance
    nearbyWarehouses.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return nearbyWarehouses;
  }

  /// Calculate estimated delivery time based on distance
  static String getEstimatedDeliveryTime(double distanceKm) {
    if (distanceKm <= 10) {
      return '30-45 minutes';
    } else if (distanceKm <= 25) {
      return '45-60 minutes';
    } else if (distanceKm <= 40) {
      return '60-90 minutes';
    } else {
      return '90-120 minutes';
    }
  }

  /// Calculate delivery fee based on distance
  static double calculateDeliveryFee(double distanceKm) {
    if (distanceKm <= 5) {
      return 0.0; // Free delivery within 5km
    } else if (distanceKm <= 15) {
      return 29.0;
    } else if (distanceKm <= 30) {
      return 49.0;
    } else {
      return 69.0;
    }
  }

  /// Calculate distance between two points in kilometers
  static double _calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    ) / 1000; // Convert meters to kilometers
  }

  /// Get the primary warehouse for a location (closest serviceable one)
  static WarehouseLocation? getPrimaryWarehouse(LatLng userLocation) {
    final result = checkServiceability(userLocation);
    return result.isServiceable ? result.nearestWarehouse : null;
  }
}

class WarehouseLocation {
  final String id;
  final String name;
  final LatLng location;
  final double serviceRadiusKm;

  const WarehouseLocation({
    required this.id,
    required this.name,
    required this.location,
    required this.serviceRadiusKm,
  });
}

class ServiceabilityResult {
  final bool isServiceable;
  final WarehouseLocation? nearestWarehouse;
  final double distanceKm;
  final String message;

  ServiceabilityResult({
    required this.isServiceable,
    required this.nearestWarehouse,
    required this.distanceKm,
    required this.message,
  });
}

class WarehouseDistance {
  final WarehouseLocation warehouse;
  final double distanceKm;

  WarehouseDistance({
    required this.warehouse,
    required this.distanceKm,
  });
}
