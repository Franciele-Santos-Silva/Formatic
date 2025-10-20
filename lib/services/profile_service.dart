import '../models/user_profile.dart';
import 'supabase_config.dart';

class ProfileService {
  final client = SupabaseConfig.client;

  Future<UserProfile?> getProfile(String userId) async {
    final response = await client.from('profiles').select().eq('id', userId).single();
    return UserProfile.fromJson(response);
  }

  Future<void> createProfile(UserProfile profile) async {
    await client.from('profiles').insert(profile.toJson());
  }
}
