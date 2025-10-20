import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://SEU-PROJECT-URL.supabase.co',
      anonKey: 'SUA-CHAVE-ANON',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
