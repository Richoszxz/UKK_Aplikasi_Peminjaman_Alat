import 'package:creaventory/export.dart';

class DetailPeminjamanService {
  final _client = SupabaseService.client;

  // Ambil detail berdasarkan id peminjaman
  Future<List<ModelDetailPeminjaman>> getDetail(int idPeminjaman) async {
    final result = await _client
        .from('detail_peminjaman')
        .select()
        .eq('id_peminjaman', idPeminjaman);

    return (result as List)
        .map((e) => ModelDetailPeminjaman.fromJson(e))
        .toList();
  }

  // Tambah detail peminjaman
  Future<void> tambahDetail(ModelDetailPeminjaman data) async {
    await _client.from('detail_peminjaman').insert(data.toJson());
  }
}
