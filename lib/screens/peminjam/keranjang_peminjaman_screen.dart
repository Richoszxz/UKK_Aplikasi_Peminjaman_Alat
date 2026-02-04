import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';
import 'package:creaventory/services/keranjang_service.dart';

class KeranjangPeminjamanScreen extends StatefulWidget {
  const KeranjangPeminjamanScreen({super.key});

  @override
  State<KeranjangPeminjamanScreen> createState() =>
      _KeranjangPeminjamanScreenState();
}

class _KeranjangPeminjamanScreenState extends State<KeranjangPeminjamanScreen> {
  final KeranjangService _keranjangService = KeranjangService();
  final PeminjamanService _peminjamanService = PeminjamanService();

  DateTime? _selectedTanggal;

  @override
  Widget build(BuildContext context) {
    final keranjangList = _keranjangService.items;

    return Scaffold(
      appBar: AppBarWidget(
        judulAppBar: "Keranjang\nPeminjaman",
        tombolKembali: true,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: keranjangList.length + 1, // tambah 1 untuk field tanggal
        itemBuilder: (context, index) {
          if (index < keranjangList.length) {
            final item = keranjangList[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _cardKeranjangItem(
                context: context,
                data: item,
                index: index,
                onDelete: () {
                  _keranjangService.hapusItem(index);
                  setState(() {});
                },
                onPickDate: (date) {
                  setState(() {
                    item["tanggalKembali"] = date;
                  });
                },
              ),
            );
          } else {
            // Field tanggal universal
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _tanggalField(
                context: context,
                selectedDate: _selectedTanggal,
                onTap: () async {
                  // 1️⃣ Pilih tanggal
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedTanggal ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );

                  if (date != null) {
                    // 2️⃣ Pilih waktu setelah tanggal
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                        _selectedTanggal ?? DateTime.now(),
                      ),
                    );

                    // 3️⃣ Gabungkan tanggal + waktu
                    if (time != null) {
                      setState(() {
                        _selectedTanggal = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    } else {
                      // Kalau user batal pilih waktu, tetap pakai jam 00:00
                      setState(() {
                        _selectedTanggal = DateTime(
                          date.year,
                          date.month,
                          date.day,
                        );
                      });
                    }
                  }
                },
              ),
            );
          }
        },
      ),

      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 5,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: ElevatedButton(
              onPressed: () async {
                if (_keranjangService.items.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Keranjang masih kosong",
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                  return;
                }

                if (_selectedTanggal == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Pilih tanggal pengembalian",
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                  return;
                }

                try {
                  await _peminjamanService.mengajukanPeminjaman(
                    tanggalRencanaKembali: _selectedTanggal!,
                    items: _keranjangService.items,
                  );

                  _keranjangService.clear();

                  if (mounted) Navigator.pop(context);

                  AlertHelper.showSuccess(
                    context,
                    'Berhasil mengajukan peminjaman !',
                  );
                } on Exception catch (e) {
                  debugPrint('$e');
                  AlertHelper.showError(
                    context,
                    'Gagal mengajukan peminjaman !',
                  );
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                "Ajukan Peminjaman",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardKeranjangItem({
    required BuildContext context,
    required Map<String, dynamic> data,
    required int index,
    required VoidCallback onDelete,
    required Function(DateTime date) onPickDate,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 125,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          /// ================= INFO ALAT =================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Gambar
              ClipRRect(
                child:
                    data['gambar'] != null &&
                        data['gambar'].toString().isNotEmpty
                    ? Image.network(
                        data['gambar'],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade300,
                        ),
                        child: const Icon(Icons.image, size: 40),
                      ),
              ),

              const SizedBox(width: 12),

              /// Info
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["nama"],

                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      data["spesifikasi"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Text(
                          "Jumlah:",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),

                        SizedBox(
                          width: 30,
                          height: 25,
                          child: TextFormField(
                            initialValue: data["jumlah"].toString(),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                            ),
                            onChanged: (value) {
                              final qty = int.tryParse(value) ?? 1;
                              setState(() {
                                _keranjangService.updateJumlah(
                                  index,
                                  qty < 1 ? 1 : qty,
                                );
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// Tombol X
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tanggalField({
    required BuildContext context,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            "Rencana tanggal pengembalian",
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: const Color(0xFF424242),
            ),
          ),
        ),

        // Field yang bisa di tap
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null
                      ? "Pilih tanggal"
                      : "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
