import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/address_provider.dart';
import '../providers/auth_provider.dart';
import '../models/address_model.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AddressScreen extends StatefulWidget {
  final AddressModel? address;

  const AddressScreen({
    super.key,
    this.address,
  });

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _landmarkController = TextEditingController();
  
  AddressType _selectedType = AddressType.home;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final address = widget.address!;
    _nameController.text = address.name;
    _phoneController.text = address.phoneNumber;
    _addressLine1Controller.text = address.addressLine1;
    _addressLine2Controller.text = address.addressLine2;
    _cityController.text = address.city;
    _stateController.text = address.state;
    _pincodeController.text = address.pincode;
    _landmarkController.text = address.landmark;
    _selectedType = address.type;
    _isDefault = address.isDefault;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  void _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      
      if (authProvider.user == null) return;

      final addressData = AddressModel(
        id: widget.address?.id ?? '',
        userId: authProvider.user!.id,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
        landmark: _landmarkController.text.trim(),
        type: _selectedType,
        isDefault: _isDefault,
        createdAt: widget.address?.createdAt ?? DateTime.now(),
        updatedAt: widget.address != null ? DateTime.now() : null,
      );

      bool success;
      if (widget.address != null) {
        success = await addressProvider.updateAddress(addressData);
      } else {
        success = await addressProvider.addAddress(addressData);
      }

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.address != null 
                  ? 'Address updated successfully!'
                  : 'Address added successfully!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(addressProvider.errorMessage ?? 'Failed to save address'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.address != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Address' : 'Add New Address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contact Information
              const Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Address Information
              const Text(
                'Address Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _addressLine1Controller,
                label: 'Address Line 1',
                prefixIcon: Icons.home_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _addressLine2Controller,
                label: 'Address Line 2 (Optional)',
                prefixIcon: Icons.location_on_outlined,
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _landmarkController,
                label: 'Landmark (Optional)',
                prefixIcon: Icons.place_outlined,
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cityController,
                      label: 'City',
                      prefixIcon: Icons.location_city_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter city';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _stateController,
                      label: 'State',
                      prefixIcon: Icons.map_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter state';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _pincodeController,
                label: 'Pin Code',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.pin_drop_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pin code';
                  }
                  if (value.length != 6) {
                    return 'Please enter a valid pin code';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Address Type
              const Text(
                'Address Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTypeChip(AddressType.home, 'Home', Icons.home),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeChip(AddressType.work, 'Work', Icons.work),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeChip(AddressType.other, 'Other', Icons.location_on),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Default Address Toggle
              Row(
                children: [
                  Checkbox(
                    value: _isDefault,
                    onChanged: (value) {
                      setState(() {
                        _isDefault = value ?? false;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  const Text(
                    'Set as default address',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              Consumer<AddressProvider>(
                builder: (context, addressProvider, child) {
                  return CustomButton(
                    onPressed: addressProvider.isLoading ? null : _saveAddress,
                    isLoading: addressProvider.isLoading,
                    child: Text(isEditing ? 'Update Address' : 'Save Address'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(AddressType type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}