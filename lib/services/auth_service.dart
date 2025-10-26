import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class AuthService {
  final SupabaseClient client = SupabaseConfig.client;

  Future<AuthResponse> signUp(
    String email,
    String password,
    String username, {
    String? phone,
    String? avatarUrl,
  }) async {
    final response = await client.auth.signUp(email: email, password: password);

    // Profile creation is handled server-side via a database trigger.
    // The app should not insert profiles directly to avoid RLS issues
    // and duplicates. Return the raw signup response to the caller.

    return response;
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async => await client.auth.signOut();

  User? get currentUser => client.auth.currentUser;
}
