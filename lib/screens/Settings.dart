import 'package:flutter/material.dart';
import 'package:meat_delivery/screens/privacy_policy.dart';
import 'package:meat_delivery/screens/terms_and_conditions.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/settings_tile.dart';
import 'EditProfile.dart';
import 'AddressList.dart';
import 'OrderHistory.dart';
import 'Favourites.dart';
import 'SendFeedback.dart';
import 'About.dart';
import 'Login.dart';
import 'dart:io';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Provider.of<AuthProvider>(context, listen: false).signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Section
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.user;
                
                return Container(
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
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        backgroundImage: null, // we'll handle image manually below
                        child: user?.profileImage != null
                            ? ClipOval(
                          child: user!.profileImage!.startsWith('http')
                              ? Image.network(
                            user.profileImage!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                              : Image.file(
                            File(user.profileImage!),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Text(
                          user?.name.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'User',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (user?.phoneNumber != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                user!.phoneNumber!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Account Section
            _buildSection(
              'Account',
              [
                SettingsTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.location_on_outlined,
                  title: 'My Addresses',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddressListScreen(isSelectionMode: false),
                      ),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.history,
                  title: 'Order History',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.favorite_outline,
                  title: 'My Favourites',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FavouritesScreen()),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Support Section
            _buildSection(
              'Support',
              [
                SettingsTile(
                  icon: Icons.feedback_outlined,
                  title: 'Send Feedback',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SendFeedbackScreen()),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TermsConditionsScreen()),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Logout Section
            _buildSection(
              'Account Actions',
              [
                SettingsTile(
                  icon: Icons.logout,
                  title: 'Logout',
                  titleColor: AppColors.error,
                  iconColor: AppColors.error,
                  showArrow: false,
                  onTap: () => _handleLogout(context),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // App Version
            Text(
              'Meat Valla v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}