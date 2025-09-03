import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Replace with your actual Supabase project URL and anon key
  static const String supabaseUrl = 'https://hclwhktijsskkymzvkou.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhjbHdoa3RpanNza2t5bXp2a291Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM2MzA3MDAsImV4cCI6MjA2OTIwNjcwMH0.JZyDPl7OH25QGEenT0pU0rgLFfL6y_MLP8Q5DVdtVgo';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;

  // Instead of static getter, use a function
  static SupabaseQueryBuilder from(String table) => client.from(table);
}
