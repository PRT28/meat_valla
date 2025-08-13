import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Meat Valla'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo and Info
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  const Text(
                    'Meat Valla',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // About Content
            _buildSection(
              'Our Story',
              'Meat Valla is your trusted partner for fresh, high-quality meat delivery. We are committed to providing the finest cuts of meat, sourced directly from trusted suppliers, and delivered fresh to your doorstep.',
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              'Our Mission',
              'To revolutionize the way people buy meat by providing convenient, reliable, and hygienic meat delivery services while maintaining the highest standards of quality and freshness.',
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              'Why Choose Meat Valla?',
              '• 100% Fresh and Hygienic Meat\n• Sourced from Trusted Suppliers\n• Quick & Reliable Delivery\n• Competitive Prices\n• Cash on Delivery Available\n• Quality Guaranteed',
            ),
            
            const SizedBox(height: 32),
            
            // Contact Information
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Us',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildContactItem(
                    Icons.phone,
                    'Phone',
                    '+91 98765 43210',
                    () => _launchURL('tel:+919876543210'),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildContactItem(
                    Icons.email,
                    'Email',
                    'support@meatvalla.com',
                    () => _launchURL('mailto:support@meatvalla.com'),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildContactItem(
                    Icons.language,
                    'Website',
                    'www.meatvalla.com',
                    () => _launchURL('https://www.meatvalla.com'),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildContactItem(
                    Icons.location_on,
                    'Address',
                    '123 Business Park, Mumbai, India',
                    null,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Social Media
            Center(
              child: Column(
                children: [
                  const Text(
                    'Follow Us',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        Icons.facebook,
                        () => _launchURL('https://facebook.com/meatvalla'),
                      ),
                      const SizedBox(width: 16),
                      _buildSocialButton(
                        Icons.alternate_email,
                        () => _launchURL('https://twitter.com/meatvalla'),
                      ),
                      const SizedBox(width: 16),
                      _buildSocialButton(
                        Icons.camera_alt,
                        () => _launchURL('https://instagram.com/meatvalla'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Legal
            Center(
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {
                      // Navigate to Privacy Policy
                    },
                    child: const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to Terms & Conditions
                    },
                    child: const Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Copyright
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

  Widget _buildContactItem(
    IconData icon,
    String label,
    String value,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: onTap != null ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textLight,
            ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
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
    );
  }
}