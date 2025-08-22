import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Introduction',
              'Welcome to Meat Valla! By using our services, you agree to comply with and be bound by the following terms and conditions.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Order Placement',
              '• All orders are subject to acceptance and availability.\n'
                  '• We reserve the right to cancel any order due to unforeseen circumstances.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Payment',
              '• Payments must be completed before delivery.\n'
                  '• We accept online payments and cash on delivery where applicable.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Delivery',
              '• We strive to deliver fresh meat within the promised time.\n'
                  '• Delivery times may vary depending on location and availability.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Liability',
              '• Meat Valla is not responsible for any indirect or incidental losses.\n'
                  '• We ensure the highest quality, but in case of issues, please contact support for resolution.',
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                '© 2024 Meat Valla. All rights reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
