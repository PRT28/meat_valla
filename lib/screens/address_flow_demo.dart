import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import 'Address.dart';

class AddressFlowDemoScreen extends StatelessWidget {
  const AddressFlowDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Address Flow Demo'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'New Location-Based Address Flow',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Experience the modern address flow similar to Zomato/Swiggy:',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Features List
            _buildFeatureItem(
              icon: Icons.my_location,
              title: 'Auto Location Detection',
              description: 'Automatically detects your current location using GPS',
            ),
            
            const SizedBox(height: 20),
            
            _buildFeatureItem(
              icon: Icons.map,
              title: 'Interactive Map',
              description: 'Adjust your location precisely on an interactive map',
            ),
            
            const SizedBox(height: 20),
            
            _buildFeatureItem(
              icon: Icons.search,
              title: 'Place Search',
              description: 'Search for specific locations, areas, or landmarks',
            ),
            
            const SizedBox(height: 20),
            
            _buildFeatureItem(
              icon: Icons.location_city,
              title: 'Auto Address Fill',
              description: 'Automatically fills address details from coordinates',
            ),
            
            const SizedBox(height: 20),
            
            _buildFeatureItem(
              icon: Icons.money_off,
              title: 'Zero Cost',
              description: 'Uses free OpenStreetMap and Photon geocoding services',
            ),
            
            const Spacer(),
            
            // Demo Button
            CustomButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddressScreen(),
                  ),
                );
              },
              child: const Text('Try New Address Flow'),
            ),
            
            const SizedBox(height: 16),
            
            // Info Text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Make sure to enable location permissions for the best experience.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
