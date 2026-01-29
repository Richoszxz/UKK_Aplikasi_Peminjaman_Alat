import 'model_detail_peminjaman.dart';

class ModelPeminjaman {
  final int idPeminjaman;
  final String idUser;
  final String? namaUser;
  final DateTime tanggalPeminjaman;
  final DateTime tanggalKembaliRencana;
  final String statusPeminjaman;
  final String? kodePeminjaman;
  final String? disetujuiOleh;
  final String? namaPenyetuju;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final List<ModelDetailPeminjaman> detailPeminjaman;

  ModelPeminjaman({
    required this.idPeminjaman,
    required this.idUser,
    this.namaUser,
    required this.tanggalPeminjaman,
    required this.tanggalKembaliRencana,
    required this.statusPeminjaman,
    this.kodePeminjaman,
    this.disetujuiOleh,
    this.namaPenyetuju,
    this.createdAt,
    this.updatedAt,
    this.detailPeminjaman = const [],
  });

  factory ModelPeminjaman.fromJson(Map<String, dynamic> map) {
    return ModelPeminjaman(
      idPeminjaman: map['id_peminjaman'],
      idUser: map['id_user'],
      namaUser: map['peminjam'] != null ? map['peminjam']['username'] : null,
      tanggalPeminjaman: DateTime.parse(map['tanggal_peminjaman']),
      tanggalKembaliRencana: DateTime.parse(map['tanggal_kembali_rencana']),
      statusPeminjaman: map['status_peminjaman'],
      kodePeminjaman: map['kode_peminjaman'],
      disetujuiOleh: map['disetujui_oleh'],
      namaPenyetuju: map['penyetuju'] != null
          ? map['penyetuju']['username']
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
      detailPeminjaman: map['detail_peminjaman'] != null
          ? (map['detail_peminjaman'] as List)
                .map((e) => ModelDetailPeminjaman.fromJson(e))
                .toList()
          : [],
    );
  }
}
