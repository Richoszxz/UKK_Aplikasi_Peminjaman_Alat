import 'model_peminjaman.dart';

class ModelPengembalian {
  final int idPengembalian;
  final int idPeminjaman;
  final DateTime tanggalKembaliAsli;
  final int? terlambatHari;
  final double? totalDenda;
  final double? dendaTerlambat;
  final String? dikonfirmasiOleh;

  final List<ModelPeminjaman> peminjaman;

  ModelPengembalian({
    required this.idPengembalian,
    required this.idPeminjaman,
    required this.tanggalKembaliAsli,
    this.terlambatHari,
    this.totalDenda,
    this.dendaTerlambat,
    this.dikonfirmasiOleh,
    this.peminjaman = const [],
  });

  factory ModelPengembalian.fromJson(Map<String, dynamic> map) {
    final peminjaman = map['peminjaman'];
    return ModelPengembalian(
      idPengembalian: map['id_pengembalian'],
      idPeminjaman: map['id_peminjaman'],
      tanggalKembaliAsli: DateTime.parse(map['tanggal_kembali_asli']),
      terlambatHari: map['terlambat_hari'],
      totalDenda: map['total_denda'] != null
          ? double.parse(map['total_denda'].toString())
          : null,
      dendaTerlambat: map['denda_terlambat'] != null
          ? double.parse(map['denda_terlambat'].toString())
          : null,
      dikonfirmasiOleh: map['dikonfirmasi_oleh'],
      peminjaman: peminjaman != null
          ? [ModelPeminjaman.fromJson(peminjaman)]
          : [],
    );
  }
}
