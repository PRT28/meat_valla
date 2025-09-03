import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/delivery_service.dart';
import '../utils/app_colors.dart';

class DeliveryTestScreen extends StatefulWidget {
  const DeliveryTestScreen({super.key});

  @override
  State<DeliveryTestScreen> createState() => _DeliveryTestScreenState();
}

class _DeliveryTestScreenState extends State<DeliveryTestScreen> {
  final List<TestLocation> _testLocations = [
    TestLocation('Delhi Center', LatLng(28.6139, 77.2090)), // Should be serviceable
    TestLocation('Mumbai Center', LatLng(19.0760, 72.8777)), // Should be serviceable
    TestLocation('Bangalore Center', LatLng(12.9716, 77.5946)), // Should be serviceable
    TestLocation('Gurgaon', LatLng(28.4595, 77.0266)), // Should be serviceable (near Delhi)
    TestLocation('Noida', LatLng(28.5355, 77.3910)), // Should be serviceable (near Delhi)
    TestLocation('Faridabad', LatLng(28.4089, 77.3178)), // Should be serviceable (near Delhi)
    TestLocation('Agra', LatLng(27.1767, 78.0081)), // Should NOT be serviceable (too far from Delhi)
    TestLocation('Jaipur', LatLng(26.9124, 75.7873)), // Should NOT be serviceable
    TestLocation('Shimla', LatLng(31.1048, 77.1734)), // Should NOT be serviceable
    TestLocation('Chandigarh', LatLng(30.7333, 76.7794)), // Should NOT be serviceable
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Service Test'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.primary.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery Service Area Test',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Testing 50km radius delivery validation from warehouses',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildLegendItem(Colors.green, 'Serviceable'),
                    const SizedBox(width: 20),
                    _buildLegendItem(Colors.red, 'Not Serviceable'),
                  ],
                ),
              ],
            ),
          ),

          // Warehouse Info
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Warehouses:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: DeliveryService.warehouses.map((warehouse) => Chip(
                    label: Text(
                      warehouse.name,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                  )).toList(),
                ),
              ],
            ),
          ),

          const Divider(),

          // Test Results
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _testLocations.length,
              itemBuilder: (context, index) {
                final testLocation = _testLocations[index];
                final result = DeliveryService.checkServiceability(testLocation.location);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              result.isServiceable ? Icons.check_circle : Icons.cancel,
                              color: result.isServiceable ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                testLocation.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: result.isServiceable 
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: result.isServiceable ? Colors.green : Colors.red,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                result.isServiceable ? 'SERVICEABLE' : 'NOT SERVICEABLE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: result.isServiceable ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        if (result.isServiceable && result.nearestWarehouse != null) ...[
                          Text(
                            '📍 Nearest: ${result.nearestWarehouse!.name}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '📏 Distance: ${result.distanceKm.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '🚚 Est. Delivery: ${DeliveryService.getEstimatedDeliveryTime(result.distanceKm)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '💰 Delivery Fee: ₹${DeliveryService.calculateDeliveryFee(result.distanceKm).toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ] else ...[
                          Text(
                            result.message,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class TestLocation {
  final String name;
  final LatLng location;

  TestLocation(this.name, this.location);
}
