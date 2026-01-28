import 'package:creaventory/export.dart';

class ProfilService {
  Future<Map<String, dynamic>?> ambilInfoUser() async {
    final idUser = SupabaseService.client.auth.currentUser?.id;

    if (idUser == null) return null;

    final response = await SupabaseService.client
        .from('pengguna')
        .select()
        .eq('id_user', idUser)
        .single();

    return response;
  }
}
