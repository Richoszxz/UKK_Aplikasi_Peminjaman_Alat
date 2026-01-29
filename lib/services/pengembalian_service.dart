import 'package:creaventory/export.dart';

class PengembalianService {
  final _client = SupabaseService.client;

  // Ambil semua pengembalian
  Future<List<ModelPengembalian>> ambilPengembalian() async {
  final result = await _client.from('pengembalian').select('''
    *,
    peminjaman:peminjaman!pengembalian_id_peminjaman_fkey (
      tanggal_pinjam,
      pengguna:pengguna!peminjaman_id_user_fkey ( username )
    )
  ''').order('created_at', ascending: false);

  return (result as List)
      .map((e) => ModelPengembalian.fromJson(e))
      .toList();
}

  // Tambah pengembalian
  Future<void> tambahPengembalian(ModelPengembalian data) async {
    await _client.from('pengembalian').insert(data.toJson());
  }
}
