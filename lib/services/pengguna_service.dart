import 'package:creaventory/export.dart';

class PenggunaService {
  final _supabaseService = SupabaseService.client;

  Future<List<ModelPengguna>> ambilPengguna() async {
    try {
      final response = await _supabaseService
          .from('pengguna')
          .select()
          .eq('role', 'peminjam')
          .eq('status', true);

      return (response as List<dynamic>)
          .map((item) => ModelPengguna.fromMap(item))
          .toList();
    } on Exception catch (e) {
      throw Exception('Gagal mengambil pengguna $e');
    }
  }

  Future<List<ModelPengguna>> ambilPenggunaButuhPersetujuan() async {
    try {
      final response = await _supabaseService
          .from('pengguna')
          .select()
          .eq('status', false);

      return (response as List<dynamic>)
          .map((item) => ModelPengguna.fromMap(item))
          .toList();
    } on Exception catch (e) {
      throw Exception('Gagal mengambil pengguna $e');
    }
  }

  Future<void> tombolPenggunaDisetujui(String idUser) async {
    try {
      await _supabaseService
          .from('pengguna')
          .update({'status': true})
          .eq('id_user', idUser);
    } on Exception catch (e) {
      throw Exception('Gagal menyetujui pengguna ! $e');
    }
  }

  Future<void> editPengguna(String idUser, Map<String, dynamic> dataBaru) async {
    try {
      await _supabaseService
          .from('pengguna')
          .update(dataBaru)
          .eq('id_user', idUser);
    } on Exception catch (e) {
      throw Exception('Gagal memperbarui data pengguna: $e');
    }
  }
  
  Future<void> hapusPengguna(String idUser) async {
    try {
      await _supabaseService
          .from('pengguna')
          .delete()
          .eq('id_user', idUser);
    } on Exception catch (e) {
      throw Exception('Gagal menghapus pengguna: $e');
    }
  }
}
