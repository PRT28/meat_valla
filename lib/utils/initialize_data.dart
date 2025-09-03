import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../supabase_options.dart';

/// Temporary script to initialize sample data in Supabase
/// Run this once after setting up your Supabase project
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Supabase
    await SupabaseConfig.initialize();
    print('Supabase initialized successfully');
    
    // Initialize sample data
    print('Starting sample data initialization...');
    await SupabaseService.initializeSampleData();
    print('Sample data initialization completed!');
    
  } catch (e) {
    print('Error during initialization: $e');
  }
}
