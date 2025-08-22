import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Introduction',
              'At Meat Valla, we respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and safeguard your information when you use our services.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Information We Collect',
              '• Personal information such as name, phone number, and address.\n'
                  '• Payment and transaction details.\n'
                  '• Usage data such as app activity and preferences.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'How We Use Your Data',
              '• To process and deliver your orders.\n'
                  '• To improve our services and customer experience.\n'
                  '• To communicate important updates and promotions.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Data Sharing & Security',
              'We do not sell your personal information. Data may be shared with trusted partners to fulfill your orders. We implement industry-standard security measures to protect your information.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Your Rights',
              'You can access, update, or delete your personal information at any time by contacting us at support@meatvalla.com.',
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
