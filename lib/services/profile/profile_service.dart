import 'dart:io';
import 'package:formatic/models/auth/user_profile.dart';
import '../core/supabase_config.dart';

class ProfileService {
  final client = SupabaseConfig.client;
  static const String _avatarBucket = 'avatars';
  
  Future<UserProfile?> getProfile(String userId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return UserProfile.fromJson(response);
  }

  Future<void> createProfile(UserProfile profile) async {
    await client.from('profiles').insert(profile.toJson());
  }

  Future<void> patchProfile(String userId, Map<String, dynamic> updates) async {
    await client.from('profiles').update(updates).eq('id', userId);
  }

  Future<void> deleteProfile(String userId) async {
    await client.from('profiles').delete().eq('id', userId);
  }

Future<String?> uploadAvatarFile(File file, String userId) async {
  try {
    final path = '$userId/avatar.jpg';
    
    await client.storage
      .from(_avatarBucket)
      .upload(path, file);
    
    return client.storage
      .from(_avatarBucket)
      .getPublicUrl(path);
  } catch (e) {
    return null;
  }
}

}

