import '../models/user_profile.dart';
import 'supabase_config.dart';

class ProfileService {
  final client = SupabaseConfig.client;

  // CONSULTAR PERFIL
  Future<UserProfile?> getProfile(String userId) async {
    final response = await client.from('profiles').select().eq('id', userId).single();
    return UserProfile.fromJson(response);
  }

  // CRIAR PERFIL
  Future<void> createProfile(UserProfile profile) async {
    await client.from('profiles').insert(profile.toJson());
  }

  // ATUALIZAR PARCIALMENTE
  Future<void> patchProfile(String userId, Map<String, dynamic> updates) async {
    await client.from('profiles').update(updates).eq('id', userId);
  }

  // DELETAR PERFIL
  Future<void> deleteProfile(String userId) async {
    await client.from('profiles').delete().eq('id', userId);
  }
}


