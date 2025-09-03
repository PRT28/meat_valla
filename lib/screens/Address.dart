import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/address_provider.dart';
import '../providers/auth_provider.dart';
import '../models/address_model.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/location_service.dart';
import '../services/delivery_service.dart';
import '../screens/location_picker_screen.dart';
import 'package:latlong2/latlong.dart';

class AddressScreen extends StatefulWidget {
  final AddressModel? address;

  const AddressScreen({
    super.key,
    this.address,
  });

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

final Map<String, List<String>> indianStatesAndCities = {
  'Andhra Pradesh': ['Visakhapatnam', 'Vijayawada', 'Guntur'],
  'Arunachal Pradesh': ['Itanagar', 'Tawang'],
  'Assam': ['Guwahati', 'Dibrugarh', 'Silchar'],
  'Bihar': ['Patna', 'Gaya', 'Muzaffarpur'],
  'Chhattisgarh': ['Raipur', 'Bhilai', 'Bilaspur'],
  'Goa': ['Panaji', 'Vasco da Gama', 'Margao'],
  'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot'],
  'Haryana': ['Chandigarh', 'Faridabad', 'Gurugram'],
  'Himachal Pradesh': ['Shimla', 'Manali', 'Dharamshala'],
  'Jharkhand': ['Ranchi', 'Jamshedpur'],
  'Karnataka': ['Bengaluru', 'Mysuru', 'Mangalore'],
  'Kerala': ['Thiruvananthapuram', 'Kochi', 'Kozhikode'],
  'Madhya Pradesh': ['Bhopal', 'Indore', 'Gwalior'],
  'Maharashtra': ['Mumbai', 'Pune', 'Nagpur'],
  'Manipur': ['Imphal'],
  'Meghalaya': ['Shillong'],
  'Mizoram': ['Aizawl'],
  'Nagaland': ['Kohima'],
  'Odisha': ['Bhubaneswar', 'Cuttack'],
  'Punjab': ['Chandigarh', 'Amritsar'],
  'Rajasthan': ['Jaipur', 'Udaipur', 'Jodhpur'],
  'Sikkim': ['Gangtok'],
  'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai'],
  'Telangana': ['Hyderabad'],
  'Tripura': ['Agartala'],
  'Uttar Pradesh': ['Lucknow', 'Kanpur', 'Varanasi'],
  'Uttarakhand': ['Dehradun', 'Nainital', 'Haldwani', 'Kashipur', 'Nainital', 'Bhimtal'],
  'West Bengal': ['Kolkata', 'Howrah', 'Siliguri'],
};

// final Map<String, List<String>> indianStatesAndCities = {
//   'Uttarakhand': ['Dehradun', 'Nainital', 'Haldwani', 'Kashipur', 'Nainital', 'Bhimtal'],
// };


class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _pincodeController = TextEditingController();
  final _landmarkController = TextEditingController();

  LatLng? _selectedLocation;
  AddressInfo? _addressInfo;
  ServiceabilityResult? _serviceabilityResult;
  String? _selectedState;
  String? _selectedCity;

  AddressType _selectedType = AddressType.home;
  bool _isDefault = false;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _populateFields();
    } else {
      // For new addresses, try to get current location
      _getCurrentLocationAndProceed();
    }
  }

  void _populateFields() {
    final address = widget.address!;
    _nameController.text = address.name;
    _phoneController.text = address.phoneNumber;
    _addressLine1Controller.text = address.addressLine1;
    _addressLine2Controller.text = address.addressLine2;
    _selectedCity = address.city;
    _selectedState = address.state;
    _pincodeController.text = address.pincode;
    _landmarkController.text = address.landmark;
    _selectedType = address.type;
    _isDefault = address.isDefault;

    // Set location if available
    if (address.latitude != null && address.longitude != null) {
      _selectedLocation = LatLng(address.latitude!, address.longitude!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _pincodeController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocationAndProceed() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final location = await LocationService.getCurrentLocation();
      if (location != null) {
        setState(() {
          _selectedLocation = location;
        });
        await _loadAddressFromLocation(location);
      }
    } catch (e) {
      print('Error getting current location: $e');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _loadAddressFromLocation(LatLng location) async {
    try {
      final addressInfo = await LocationService.reverseGeocode(location);
      final serviceabilityResult = DeliveryService.checkServiceability(location);

      if (addressInfo != null) {
        setState(() {
          _addressInfo = addressInfo;
          _serviceabilityResult = serviceabilityResult;
          _addressLine1Controller.text = '${addressInfo.houseNumber} ${addressInfo.road}'.trim();
          _addressLine2Controller.text = addressInfo.suburb;
          _pincodeController.text = addressInfo.postcode;
          _landmarkController.text = '';

          // Try to match state and city from the predefined list
          _matchStateAndCity(addressInfo.state, addressInfo.city);
        });

        // Show warning if location is not serviceable
        if (!serviceabilityResult.isServiceable) {
          _showServiceabilityWarning(serviceabilityResult);
        }
      }
    } catch (e) {
      print('Error loading address from location: $e');
    }
  }

  void _showServiceabilityWarning(ServiceabilityResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(result.message)),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Change Location',
          textColor: Colors.white,
          onPressed: _openLocationPicker,
        ),
      ),
    );
  }

  void _matchStateAndCity(String stateName, String cityName) {
    // Find matching state
    String? matchedState;
    String? matchedCity;

    for (String state in indianStatesAndCities.keys) {
      if (state.toLowerCase().contains(stateName.toLowerCase()) ||
          stateName.toLowerCase().contains(state.toLowerCase())) {
        matchedState = state;

        // Find matching city in this state
        final cities = indianStatesAndCities[state]!;
        for (String city in cities) {
          if (city.toLowerCase().contains(cityName.toLowerCase()) ||
              cityName.toLowerCase().contains(city.toLowerCase())) {
            matchedCity = city;
            break;
          }
        }
        break;
      }
    }

    setState(() {
      _selectedState = matchedState;
      _selectedCity = matchedCity;
    });
  }

  void _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);

      if (authProvider.user == null) return;

      // Check if location is serviceable before saving
      if (_selectedLocation != null) {
        final serviceabilityResult = DeliveryService.checkServiceability(_selectedLocation!);
        if (!serviceabilityResult.isServiceable) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cannot save address: ${serviceabilityResult.message}',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Change Location',
                textColor: Colors.white,
                onPressed: _openLocationPicker,
              ),
            ),
          );
          return;
        }
      }

      final addressData = AddressModel(
        id: widget.address?.id ?? '',
        userId: authProvider.user!.id,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim(),
        city: _selectedCity!,
        state: _selectedState!,
        pincode: _pincodeController.text.trim(),
        landmark: _landmarkController.text.trim(),
        type: _selectedType,
        isDefault: _isDefault,
        latitude: _selectedLocation?.latitude,
        longitude: _selectedLocation?.longitude,
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

  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLocation: _selectedLocation,
        ),
      ),
    );

    if (result != null) {
      final location = result['location'] as LatLng;
      final addressInfo = result['addressInfo'] as AddressInfo;
      final serviceabilityResult = result['serviceabilityResult'] as ServiceabilityResult?;

      setState(() {
        _selectedLocation = location;
        _addressInfo = addressInfo;
        _serviceabilityResult = serviceabilityResult;
      });

      await _loadAddressFromLocation(location);
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
              
              // Location Section
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              // Location Card
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    if (_isLoadingLocation)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Text('Getting your location...'),
                          ],
                        ),
                      )
                    else if (_selectedLocation != null && _addressInfo != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _serviceabilityResult?.isServiceable == true
                                      ? Icons.location_pin
                                      : Icons.location_off,
                                  color: _serviceabilityResult?.isServiceable == true
                                      ? AppColors.primary
                                      : Colors.red,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _addressInfo!.city.isNotEmpty
                                            ? _addressInfo!.city
                                            : 'Selected Location',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _addressInfo!.formattedAddress,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Serviceability status
                            if (_serviceabilityResult != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _serviceabilityResult!.isServiceable
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _serviceabilityResult!.isServiceable
                                        ? Colors.green
                                        : Colors.red,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _serviceabilityResult!.isServiceable
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: _serviceabilityResult!.isServiceable
                                          ? Colors.green
                                          : Colors.red,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        _serviceabilityResult!.isServiceable
                                            ? 'Delivery Available • ${_serviceabilityResult!.distanceKm.toStringAsFixed(1)}km from ${_serviceabilityResult!.nearestWarehouse?.name}'
                                            : 'Area Not Serviceable',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _serviceabilityResult!.isServiceable
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.location_off, color: Colors.grey[400]),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'No location selected',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Change Location Button
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: AppColors.border)),
                      ),
                      child: TextButton.icon(
                        onPressed: _openLocationPicker,
                        icon: const Icon(Icons.edit_location),
                        label: Text(_selectedLocation != null ? 'Change Location' : 'Select Location'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Address Details
              const Text(
                'Address Details',
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

                 DropdownButtonFormField<String>(
                  value: _selectedState,
                  decoration: const InputDecoration(
                    labelText: 'State',
                    prefixIcon: Icon(Icons.map_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: indianStatesAndCities.keys
                      .map((state) => DropdownMenuItem(
                    value: state,
                    child: SizedBox(
                        width: 275,
                        child: Text(state)
                    ),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedState = value;
                      _selectedCity = null; // reset city when state changes
                    });
                  },
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Please select a state' : null,
                ),


              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_city_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _selectedState == null
                    ? []
                    : indianStatesAndCities[_selectedState]!
                    .map((city) => DropdownMenuItem(
                  value: city,
                  child: Text(city),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value;
                  });
                },
                validator: (value) =>
                value == null || value.isEmpty ? 'Please select a city' : null,
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