import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tripmate_mobile/models/mobil_model.dart';

class CardMobilBaru extends StatelessWidget {
  final MobilModel mobil;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CardMobilBaru({
    Key? key,
    required this.mobil,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  String formatHarga(int harga) {
    return harga.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kiri: Label & gambar mobil
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Mobil Pribadi",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: mobil.imageBase64.isNotEmpty
                    ? Image.memory(
                        base64Decode(mobil.imageBase64),
                        width: 120,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 120,
                        height: 80,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.directions_car, size: 40),
                      ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Kanan: Informasi dan tombol
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mobil.merk,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Image.asset('assets/icons/seat.png', width: 18, height: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${mobil.jumlahPenumpang}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Image.asset('assets/icons/drive.png', width: 18, height: 18),
                    const SizedBox(width: 6),
                    Text(
                      mobil.tipeMobil,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Harga
                Text(
                  'Rp ${formatHarga(mobil.hargaSewa)}/hari',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(height: 12),

                // Tombol Edit & Hapus
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 14),
                      label: const Text("Edit"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, size: 14),
                      label: const Text("Hapus"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
