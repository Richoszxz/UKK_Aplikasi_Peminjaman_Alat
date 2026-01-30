class ModelDetailPeminjaman {
  final int idDetailPeminjaman;
  final int idPeminjaman;
  final int idAlat;
  final int jumlahPeminjaman;
  final String? kondisiAwal;
  String? kondisiKembali;
  double? dendaKerusakan;

  final String namaAlat;
  final String? gambarAlat;
  final String kondisiAlat;
  final int stokAlat;

  ModelDetailPeminjaman({
    required this.idDetailPeminjaman,
    required this.idPeminjaman,
    required this.idAlat,
    required this.jumlahPeminjaman,
    this.kondisiAwal,
    this.kondisiKembali,
    this.dendaKerusakan,
    required this.namaAlat,
    this.gambarAlat,
    required this.kondisiAlat,
    required this.stokAlat,
  });

  factory ModelDetailPeminjaman.fromJson(Map<String, dynamic> map) {
    final alat = map['alat'];

    return ModelDetailPeminjaman(
      idDetailPeminjaman: map['id_detail_peminjaman'],
      idPeminjaman: map['id_peminjaman'],
      idAlat: map['id_alat'],
      jumlahPeminjaman: map['jumlah_peminjaman'],
      kondisiAwal: map['kondisi_awal'],
      kondisiKembali: map['kondisi_kembali'],
      dendaKerusakan: map['denda_kerusakan'] != null
          ? double.parse(map['denda_kerusakan'].toString())
          : null,
      namaAlat: alat['nama_alat'],
      gambarAlat: alat['gambar_url'],
      kondisiAlat: alat['kondisi_alat'],
      stokAlat: alat['stok_alat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_peminjaman': idPeminjaman,
      'id_alat': idAlat,
      'jumlah_peminjaman': jumlahPeminjaman,
      'kondisi_awal': kondisiAwal,
      'kondisi_kembali': kondisiKembali,
      'denda_kerusakan': dendaKerusakan,
    };
  }
}
