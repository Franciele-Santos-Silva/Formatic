// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'supabase_config.dart';

// class AuthService {
//   final SupabaseClient client = SupabaseConfig.client;

//   Future<AuthResponse> signUp(String email, String password) async {
//     return await client.auth.signUp(email: email, password: password);
//   }

//   Future<AuthResponse> signIn(String email, String password) async {
//     return await client.auth.signInWithPassword(email: email, password: password);
//   }

//   Future<void> signOut() async => await client.auth.signOut();

//   User? get currentUser => client.auth.currentUser;
// }

import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class AuthService {
  final SupabaseClient client = SupabaseConfig.client;

  Future<AuthResponse> signUp(String email, String password, String username) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
    );

    // Criar perfil após cadastro
    if (response.user != null) {
      await client.from('profiles').insert({
        'id': response.user!.id,
        'username': username,
        'email': email,
      });
    }

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

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
