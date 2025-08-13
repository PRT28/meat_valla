import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/address_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/address_card.dart';
import 'Address.dart';

class AddressListScreen extends StatefulWidget {
  final bool isSelectionMode;

  const AddressListScreen({
    super.key,
    this.isSelectionMode = true,
  });

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<AddressProvider>(context, listen: false)
            .loadAddresses(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSelectionMode ? 'Select Address' : 'My Addresses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddressScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<AddressProvider>(
        builder: (context, addressProvider, child) {
          if (addressProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (addressProvider.addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    size: 80,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No addresses found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add your delivery address to continue',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddressScreen()),
                      );
                    },
                    child: const Text('Add Address'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: addressProvider.addresses.length,
                  itemBuilder: (context, index) {
                    final address = addressProvider.addresses[index];
                    final isSelected = widget.isSelectionMode && 
                        addressProvider.selectedAddress?.id == address.id;
                    
                    return AddressCard(
                      address: address,
                      isSelected: isSelected,
                      isSelectionMode: widget.isSelectionMode,
                      onTap: () {
                        if (widget.isSelectionMode) {
                          addressProvider.selectAddress(address);
                          Navigator.of(context).pop();
                        }
                      },
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddressScreen(address: address),
                          ),
                        );
                      },
                      onDelete: () {
                        _showDeleteConfirmation(address.id);
                      },
                    );
                  },
                ),
              ),
              
              // Add New Address Button
              if (!widget.isSelectionMode)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddressScreen()),
                      );
                    },
                    child: const Text('Add New Address'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(String addressId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final addressProvider = Provider.of<AddressProvider>(context, listen: false);
              await addressProvider.deleteAddress(addressId);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}