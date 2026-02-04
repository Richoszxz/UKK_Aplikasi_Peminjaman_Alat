import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';

class DetailAlatScreen extends StatefulWidget {
  final ModelAlat alat;
  final String heroTag;
  const DetailAlatScreen({
    super.key,
    required this.alat,
    required this.heroTag,
  });

  @override
  State<DetailAlatScreen> createState() => _DetailAlatScreenState();
}

class _DetailAlatScreenState extends State<DetailAlatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(judulAppBar: "Detail Alat", tombolKembali: true),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildImage(),
            
                SizedBox(height: 10,),
            
                // nama alat
                Text(
                  widget.alat.namaAlat,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                  ),
                ),
            
                // kat alat
                Text(
                  widget.alat.namaKategori.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF424242),
                  ),
                ),
            
                SizedBox(height: 15),
            
                // ================= STOK =================
                _label("Stok Alat"),
                _readonlyField(widget.alat.stokAlat.toString()),
            
                SizedBox(height: 15),
            
                // ================= SPESIFIKASI =================
                _label("Spesifikasi"),
                _readonlyField(widget.alat.spesifikasiAlat.toString(), maxLines: 2),
            
                SizedBox(height: 15),
            
                // ================= DESKRIPSI =================
                _label("Deskripsi"),
                _readonlyField(widget.alat.deskripsiAlat.toString(), maxLines: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final String? imageUrl = widget.alat.gambarUrl;

    // Jika belum ada gambar
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Icon(
            Icons.image_not_supported_rounded,
            size: 50,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      );
    }

    // Jika ada gambar (URL dari Supabase / Network)
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        imageUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 180,
            width: double.infinity,
            color: Colors.grey.shade300,
            child: const Center(child: Icon(Icons.broken_image, size: 40)),
          );
        },
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: const Color(0xFF424242),
          ),
        ),
      ),
    );
  }

  Widget _readonlyField(String value, {int maxLines = 1}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: Text(
        value,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 14,
        ),
      ),
    );
  }
}
