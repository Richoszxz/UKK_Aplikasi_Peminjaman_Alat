class ModelLog {
  final int idLog;
  final String idUser;
  final String? namaUser;
  final String judulLog;
  final String keteranganLog;
  final DateTime? waktuLog;
  final DateTime? createdAt;

  ModelLog({
    required this.idLog,
    required this.idUser,
    this.namaUser,
    required this.judulLog,
    required this.keteranganLog,
    required this.waktuLog,
    this.createdAt,
  });

  factory ModelLog.fromMap(Map<String, dynamic> map) {
    return ModelLog(
      idLog: map['id_log'],
      idUser: map['id_user'],
      namaUser: map['pengguna']?['username'],
      judulLog: map['judul_aktivitas'],
      keteranganLog: map['keterangan_aktivitas'],
      waktuLog: map['waktu_aktivitas'] != null
          ? DateTime.parse(map['waktu_aktivitas'])
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }
}
