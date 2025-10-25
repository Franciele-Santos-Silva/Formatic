// import '../models/user_profile.dart';
// import 'supabase_config.dart';

// class ProfileService {
//   final client = SupabaseConfig.client;

//   Future<UserProfile?> getProfile(String userId) async {
//     final response = await client.from('profiles').select().eq('id', userId).single();
//     return UserProfile.fromJson(response);
//   }

//   Future<void> createProfile(UserProfile profile) async {
//     await client.from('profiles').insert(profile.toJson());
//   }
// }

import '../models/user_profile.dart';
import 'supabase_config.dart';

class ProfileService {
  final client = SupabaseConfig.client;

  Future<UserProfile?> getProfile(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return UserProfile.fromJson(response);
    } catch (e) {
      print('Erro ao buscar perfil: $e');
      return null;
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    try {
      await client
          .from('profiles')
          .update(profile.toJson())
          .eq('id', profile.id);
    } catch (e) {
      print('Erro ao atualizar perfil: $e');
      rethrow;
    }
  }
}