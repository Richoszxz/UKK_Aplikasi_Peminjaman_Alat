import 'package:creaventory/export.dart';
import 'package:flutter/widgets.dart';

class PengembalianService {
  final _client = SupabaseService.client;

  // Ambil semua pengembalian
  Future<List<ModelPengembalian>> ambilPengembalian() async {
    final result = await _client
        .from('pengembalian')
        .select('''
          *, 
          pengonfirmasi:pengguna!pengembalian_dikonfirmasi_oleh_fkey(
          username
          ),
          peminjaman(
          id_peminjaman,
          id_user,
          tanggal_peminjaman,
          tanggal_kembali_rencana,
          status_peminjaman,
          kode_peminjaman,
          peminjam:pengguna!peminjaman_id_user_fkey (
                    username
                  ),
          detail_peminjaman (
          id_detail_peminjaman,
          id_peminjaman,
          id_alat,
          jumlah_peminjaman,
          kondisi_awal,
          kondisi_kembali,
          alat (
            nama_alat,
            gambar_url,
            kondisi_alat,
            stok_alat
            )
          )
        )
          
          ''')
        .order('created_at', ascending: false);

    // Debug hasil query
    debugPrint("Result type: ${result.runtimeType}");
    debugPrint("Result content: $result");

    // Pastikan result adalah List<Map<String,dynamic>>
    if (result is List) {
      return result
          .map(
            (item) => ModelPengembalian.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    // Jika bukan list, kembalikan list kosong
    return [];
  }

  Future<void> hapusPengembalian(int idPengembalian) async {
    await _client
        .from('pengembalian')
        .delete()
        .eq('id_pengembalian', idPengembalian);
  }
}
