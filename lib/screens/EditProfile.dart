import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phoneNumber ?? '';
      _profileImagePath = user.profileImage;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.of(context).pop();
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    _profileImagePath = image.path;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.of(context).pop();
                final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    _profileImagePath = image.path;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.updateProfile(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        profileImage: _profileImagePath,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to update profile'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Profile Image
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceVariant,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _profileImagePath != null
                          ? ClipOval(
                              child: _profileImagePath!.startsWith('http')
                                  ? Image.network(
                                      _profileImagePath!,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                    )
                                  : Image.asset(
                                      _profileImagePath!,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                    ),
                            )
                          : Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                return Center(
                                  child: Text(
                                    authProvider.user?.name.substring(0, 1).toUpperCase() ?? 'U',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Name Field
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  if (value.length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Phone Field
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Email Field (Read-only)
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return CustomTextField(
                    controller: TextEditingController(text: authProvider.user?.email ?? ''),
                    label: 'Email Address',
                    enabled: false,
                    prefixIcon: Icons.email_outlined,
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Save Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return CustomButton(
                    onPressed: authProvider.isLoading ? null : _saveProfile,
                    isLoading: authProvider.isLoading,
                    child: const Text('Save Changes'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}