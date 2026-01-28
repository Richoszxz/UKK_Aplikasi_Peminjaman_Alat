class ModelKategori {
  final int? idKategori;
  final String namaKategori;
  final String? deskripsiKategori;
  final DateTime? createdAt;

  ModelKategori({
    this.idKategori,
    required this.namaKategori,
    this.deskripsiKategori,
    this.createdAt
  });

  factory ModelKategori.fromMap(Map<String, dynamic> map) {
    return ModelKategori(
      idKategori: map['id_kategori'],
      namaKategori: map['nama_kategori'],
      deskripsiKategori: map['deskripsi_kategori'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }
}