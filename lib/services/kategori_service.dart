import 'package:creaventory/export.dart';

class KategoriService {
  final _supabaseService = SupabaseService.client;

  Future<List<ModelKategori>> ambilKategori() async {
    try {
      final response = await _supabaseService.from('kategori').select();

      return (response as List<dynamic>)
          .map((item) => ModelKategori.fromMap(item))
          .toList();
    } on Exception catch (e) {
      throw Exception('Gagal mengambil kategori $e');
    }
  }

  // CREATE
  Future<void> tambahKategori(String nama, String deskripsi) async {
    await _supabaseService.from('kategori').insert({
      'nama_kategori': nama,
      'deskripsi_kategori': deskripsi,
    });
  }

  // UPDATE
  Future<void> editKategori(int id, String nama, String deskripsi) async {
    await _supabaseService
        .from('kategori')
        .update({'nama_kategori': nama, 'deskripsi_kategori': deskripsi})
        .eq('id_kategori', id);
  }

  // DELETE
  Future<void> hapusKategori(int id) async {
    await _supabaseService.from('kategori').delete().eq('id_kategori', id);
  }
}
