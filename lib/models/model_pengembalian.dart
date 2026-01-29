import 'model_peminjaman.dart';
import 'model_detail_peminjaman.dart';

class ModelPengembalian {
  final int idPengembalian;
  final int idPeminjaman;
  final DateTime tanggalKembaliAsli;
  final int? terlambatHari;
  final double? totalDenda;
  final double? dendaTerlambat;
  final String? dikonfirmasiOleh;

  final List<ModelPeminjaman> peminjaman;
  final List<ModelDetailPeminjaman> detailPeminjaman;

  ModelPengembalian({
    required this.idPengembalian,
    required this.idPeminjaman,
    required this.tanggalKembaliAsli,
    this.terlambatHari,
    this.totalDenda,
    this.dendaTerlambat,
    this.dikonfirmasiOleh,
    this.peminjaman = const [],
    this.detailPeminjaman = const [],
  });

  factory ModelPengembalian.fromJson(Map<String, dynamic> map) {
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
      peminjaman: map['peminjaman'] != null
          ? (map['peminjaman'] as List)
                .map((item) => ModelPeminjaman.fromJson(item))
                .toList()
          : [],
      detailPeminjaman: map['detail_peminjaman'] != null
          ? (map['detail_peminjaman'] as List)
                .map((item) => ModelDetailPeminjaman.fromJson(item))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_peminjaman': idPeminjaman,
      'tanggal_kembali_asli': tanggalKembaliAsli.toIso8601String(),
      'terlambat_hari': terlambatHari,
      'total_denda': totalDenda,
      'denda_terlambat': dendaTerlambat,
      'dikonfirmasi_oleh': dikonfirmasiOleh,
    };
  }
}
