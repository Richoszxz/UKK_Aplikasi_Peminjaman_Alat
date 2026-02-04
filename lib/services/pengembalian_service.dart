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
                    username,
                    email
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
    return result.map((item) => ModelPengembalian.fromJson(item)).toList();
  }

  Future<void> hapusPengembalian(int idPengembalian) async {
    await _client
        .from('pengembalian')
        .delete()
        .eq('id_pengembalian', idPengembalian);
  }

  Future<void> ajukanPengembalian({
    required int id_peminjaman,
    String? catatan,
  }) async {
    await _client.rpc(
      'peminjam_mengajukan_pengembalian',
      params: {'p_id_peminjaman': id_peminjaman, 'p_catatan': catatan},
    );
  }

  Future<void> konfirmasiPengembalian({
    required int idPengembalian,
    required String idPetugas,
    required List<Map<String, dynamic>> detailPengembalian,
  }) async {
    try {
      await SupabaseService.client.rpc(
        'petugas_konfirmasi_pengembalian',
        params: {
          'p_id_pengembalian': idPengembalian,
          'p_id_petugas': idPetugas,
          'p_detail': detailPengembalian,
        },
      );
    } catch (e) {
      throw Exception('Gagal $e');
    }
  }
}
