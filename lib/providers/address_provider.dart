import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/address_model.dart';
import '../supabase_options.dart';

class AddressProvider extends ChangeNotifier {
  final SupabaseClient _supabase = SupabaseConfig.client;
  
  List<AddressModel> _addresses = [];
  AddressModel? _selectedAddress;
  bool _isLoading = false;
  String? _errorMessage;

  List<AddressModel> get addresses => _addresses;
  AddressModel? get selectedAddress => _selectedAddress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AddressModel? get defaultAddress {
    try {
      return _addresses.firstWhere((address) => address.isDefault);
    } catch (e) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  Future<void> loadAddresses(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _supabase
          .from('addresses')
          .select()
          .eq('userId', userId)
          .order('isDefault', ascending: false);

      _addresses = (response as List)
          .map((data) => AddressModel.fromMap(data))
          .toList();

      // Set default selected address
      if (_selectedAddress == null && _addresses.isNotEmpty) {
        _selectedAddress = defaultAddress;
      }

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<bool> addAddress(AddressModel address) async {
    try {
      _setLoading(true);
      _clearError();

      // If this is the first address or marked as default, update others
      if (address.isDefault || _addresses.isEmpty) {
        await _updateDefaultAddress(null); // Clear existing defaults
      }

      final response = await _supabase
          .from('addresses')
          .insert(address.toCreateMap())
          .select()
          .single();

      final createdAddress = AddressModel.fromMap(response);
      _addresses.add(createdAddress);
      
      if (address.isDefault || _addresses.length == 1) {
        _selectedAddress = createdAddress;
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateAddress(AddressModel address) async {
    try {
      _setLoading(true);
      _clearError();

      if (address.isDefault) {
        await _updateDefaultAddress(address.id);
      }

      await _supabase
          .from('addresses')
          .update(address.toMap())
          .eq('id', address.id);

      final index = _addresses.indexWhere((addr) => addr.id == address.id);
      if (index != -1) {
        _addresses[index] = address;
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteAddress(String addressId) async {
    try {
      _setLoading(true);
      _clearError();

      await _supabase
          .from('addresses')
          .delete()
          .eq('id', addressId);
      
      _addresses.removeWhere((address) => address.id == addressId);
      
      if (_selectedAddress?.id == addressId) {
        _selectedAddress = defaultAddress;
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> _updateDefaultAddress(String? newDefaultId) async {
    // Update all addresses to not be default except the new one
    for (final address in _addresses) {
      if (address.isDefault && address.id != newDefaultId) {
        await _supabase
            .from('addresses')
            .update({'isDefault': false})
            .eq('id', address.id);
      }
    }

    // Update local state
    for (int i = 0; i < _addresses.length; i++) {
      if (_addresses[i].isDefault && _addresses[i].id != newDefaultId) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
  }

  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}