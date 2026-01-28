import 'package:creaventory/export.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final _supabaseService = SupabaseService.client;

  Future<String?> ambilRole(String idUser) async {
    try {
      final data = await _supabaseService
          .from('pengguna')
          .select('role')
          .eq('id_user', idUser)
          .single();
      return data['role'] as String?;
    } catch (e) {
      debugPrint("error ambil: $e");
      return null;
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    final response = await _supabaseService.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      // 1. Ambil role dari database
      String? role = await ambilRole(response.user!.id);

      if (role != null) {
        // 2. SIMPAN KE SESSION (SharedPreferences)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', role);
      }
    }
    return response;
  }

  Future<AuthResponse> signUp(
    String email,
    String password,
    String username,
  ) async {
    return await _supabaseService.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  Future<void> signOut() async {
    await _supabaseService.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role'); // Hapus session saat logout
  }
}
