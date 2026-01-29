import 'package:creaventory/export.dart';

class PeminjamanService {
  final _client = SupabaseService.client;

  // Ambil semua peminjaman
  Future<List<ModelPeminjaman>> ambilPeminjaman() async {
    final result = await _client
        .from('peminjaman')
        .select('''
        *,
        peminjam:pengguna!peminjaman_id_user_fkey (
          username
        ),
        penyetuju:pengguna!peminjaman_disetujui_oleh_fkey (
          username
        ),
        detail_peminjaman (
        id_detail_peminjaman,
        id_peminjaman,
        id_alat,
        jumlah_peminjaman,
        kondisi_awal,
        kondisi_kembali,
        denda_kerusakan,
        alat (
          nama_alat,
          gambar_url,
          kondisi_alat,
          stok_alat
        )
      )
      ''')
        .eq('status_peminjaman', 'dipinjam')
        .order('created_at', ascending: false);

    return (result as List).map((e) => ModelPeminjaman.fromJson(e)).toList();
  }

  // Tambah peminjaman
  Future<void> tambahPeminjaman({
  required String idUser,
  required DateTime tglPinjam,
  required DateTime tglRencanaKembali,
  required List<Map<String, dynamic>> detailAlat,
}) async {
  try {
    final currentUser = _client.auth.currentUser;

    if (currentUser == null) {
      throw Exception("User belum login");
    }

    // Insert peminjaman
    final peminjaman = await _client
        .from('peminjaman')
        .insert({
          'id_user': idUser,
          'tanggal_peminjaman': tglPinjam.toIso8601String(),
          'tanggal_kembali_rencana':
              tglRencanaKembali.toIso8601String(),
          'status_peminjaman': 'dipinjam',
          'disetujui_oleh': currentUser.id,
        })
        .select()
        .single();

    final int idPeminjaman = peminjaman['id_peminjaman'];

    // Insert detail peminjaman
    final detailPeminjaman = detailAlat.map((e) {
      return {
        'id_peminjaman': idPeminjaman,
        'id_alat': e['id_alat'],
        'jumlah_peminjaman': e['qty'],
      };
    }).toList();

    await _client.from('detail_peminjaman').insert(detailPeminjaman);

  } catch (e) {
    throw Exception("Gagal membuat peminjaman: $e");
  }
}


  // Update status peminjaman
  Future<void> updateStatus(int idPeminjaman, String status) async {
    await _client
        .from('peminjaman')
        .update({'status_peminjaman': status})
        .eq('id_peminjaman', idPeminjaman);
  }

  // Hapus peminjaman
  Future<void> hapusPeminjaman(int idPeminjaman) async {
    await _client.from('peminjaman').delete().eq('id_peminjaman', idPeminjaman);
  }
}
