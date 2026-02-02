class KeranjangService {
  static final KeranjangService _instance = KeranjangService._internal();
  factory KeranjangService() => _instance;
  KeranjangService._internal();

  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  int get totalItem => _items.length;

  void tambahItem(Map<String, dynamic> alat) {
    final index = _items.indexWhere((item) => item["nama"] == alat["nama"]);

    if (index != -1) {
      _items[index]["jumlah"] += 1;
    } else {
      _items.add({
        "id_alat": alat["id_alat"],
        "nama": alat["nama"],
        "spesifikasi": alat["spesifikasi"],
        "jumlah": 1,
        "gambar": alat["gambar"],
        "tanggalKembali": null,
      });
    }
  }

  void updateJumlah(int index, int jumlah) {
    _items[index]["jumlah"] = jumlah;
  }

  void hapusItem(int index) {
    _items.removeAt(index);
  }

  void setTanggalSemua(DateTime date) {
    for (var item in _items) {
      item["tanggalKembali"] = date;
    }
  }

  void clear() {
    _items.clear();
  }
}
