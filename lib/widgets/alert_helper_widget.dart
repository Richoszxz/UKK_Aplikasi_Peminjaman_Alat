import 'package:flutter/material.dart';

class AlertHelper {
  // =======================
  // ALERT SUKSES
  // =======================
  static void showSuccess(
    BuildContext context,
    String message, {
    VoidCallback? onOk,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text("Berhasil"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ✅ tutup dialog aman
                onOk?.call();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // =======================
  // ALERT ERROR
  // =======================
  static void showError(
    BuildContext context,
    String message, {
    VoidCallback? onOk,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text("Terjadi Kesalahan"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ✅ aman
                onOk?.call();
              },
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  // =======================
  // ALERT KONFIRMASI
  // =======================
  static void showConfirm(
    BuildContext context, {
    required String judul,
    required String pesan,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(judul),
          content: Text(pesan),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // tutup dialog
              },
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // tutup dialog
                onConfirm(); // jalankan aksi
              },
              child: const Text("Ya"),
            ),
          ],
        );
      },
    );
  }
}
