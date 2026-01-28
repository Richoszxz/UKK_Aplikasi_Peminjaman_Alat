class ModelAlat {
  final int idAlat;
  final String namaAlat;
  final int idKategori;
  final String? namaKategori;
  final int stokAlat;
  final String kondisiAlat;
  final String? spesifikasiAlat;
  final String? deskripsiAlat;
  final String? gambarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ModelAlat({
    required this.idAlat,
    required this.namaAlat,
    required this.idKategori,
    this.namaKategori,
    required this.stokAlat,
    required this.kondisiAlat,
    this.spesifikasiAlat,
    this.deskripsiAlat,
    this.gambarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory ModelAlat.fromMap(Map<String, dynamic> map) {
    return ModelAlat(
      idAlat: map['id_alat'],
      namaAlat: map['nama_alat'],
      idKategori: map['id_kategori'],
      namaKategori: map['kategori'] != null ? map['kategori']['nama_kategori'] : null,
      stokAlat: map['stok_alat'],
      kondisiAlat: map['kondisi_alat'],
      spesifikasiAlat: map['spesifikasi_alat'],
      deskripsiAlat: map['deskripsi_alat'],
      gambarUrl: map['gambar_url'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }
}
