import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripmate_mobile/models/vila_model.dart';

class CardVilaBaru extends StatelessWidget {
  final VilaModel vila;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CardVilaBaru({
    super.key,
    required this.vila,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern('id');
    final imageBytes = vila.imageBase64.isNotEmpty ? base64Decode(vila.imageBase64) : null;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - (screenWidth * 0.03 * 2);
    final imageWidth = cardWidth * 0.38;
    final imageHeight = 150.0;

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to vila detail page if needed
        // Navigator.push(context, MaterialPageRoute(builder: (context) => VilaDetailPage(vila: vila)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gambar vila
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: imageBytes != null
                    ? Image.memory(
                        imageBytes,
                        width: imageWidth,
                        height: imageHeight,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: imageWidth,
                        height: imageHeight,
                        color: Colors.grey[300],
                        child: const Icon(Icons.villa, size: 40, color: Colors.grey),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama vila
                      Text(
                        vila.nama,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      // Rating + reviews
                      Row(
                        children: [
                          const Icon(Icons.star, size: 15, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            "${vila.rating.toStringAsFixed(1)} (${vila.jumlahReview} reviews)",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Fasilitas utama (WiFi, Kolam, Parkir)
                      Row(
                        children: [
                          if (vila.tersediaWifi) ...[
                            const Icon(Icons.wifi, size: 16, color: Colors.green),
                            const SizedBox(width: 6),
                          ],
                          if (vila.tersediaKolam) ...[
                            const Icon(Icons.pool, size: 16, color: Colors.blue),
                            const SizedBox(width: 6),
                          ],
                          if (vila.tersediaParkir) ...[
                            const Icon(Icons.local_parking, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                          ],
                          // Tambahan fasilitas lain jika ada
                          if (vila.fasilitas.isNotEmpty) ...[
                            const Icon(Icons.more_horiz, size: 16, color: Colors.grey),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Tipe vila dengan emoji
                      Row(
                        children: [
                          Text(
                            _getVilaTypeIcon(vila.tipeVila),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            vila.tipeVila,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Kapasitas (kamar & tamu)
                      Row(
                        children: [
                          const Icon(Icons.bed, size: 15, color: Color(0xFFDC2626)),
                          const SizedBox(width: 4),
                          Text(
                            "${vila.jumlahKamar} kamar",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.people, size: 15, color: Color(0xFFDC2626)),
                          const SizedBox(width: 4),
                          Text(
                            "${vila.kapasitas} tamu",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Lokasi utama
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 15, color: Colors.red),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              vila.lokasi,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      // Lokasi detail (alamat lengkap)
                      if (vila.lokasiDetail.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.place, size: 13, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  vila.lokasiDetail,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Check-in & Check-out
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 13, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              "Check-in: ${vila.checkIn} | Check-out: ${vila.checkOut}",
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      // Deskripsi singkat
                      if (vila.deskripsi.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            vila.deskripsi,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      // Spacer untuk mendorong harga dan tombol ke bawah
                      const Spacer(),

                      // Harga per malam
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Mulai dari ',
                                style: TextStyle(fontSize: 12, color: Color(0xFFDC2626)),
                              ),
                              TextSpan(
                                text: 'Rp ${formatter.format(vila.hargaPerMalam)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                              const TextSpan(
                                text: '/malam',
                                style: TextStyle(fontSize: 12, color: Color(0xFFDC2626)),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Tombol Edit & Hapus
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildActionButton(
                            icon: Icons.edit,
                            label: 'Edit',
                            color: const Color(0xFFF0AA14),
                            onTap: onEdit,
                          ),
                          const SizedBox(width: 6),
                          _buildActionButton(
                            icon: Icons.delete,
                            label: 'Hapus',
                            color: const Color(0xFFDC2626),
                            onTap: onDelete,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method untuk mendapatkan emoji berdasarkan tipe vila
  String _getVilaTypeIcon(String tipeVila) {
    switch (tipeVila.toLowerCase()) {
      case 'vila pantai':
        return '🏖️';
      case 'vila pegunungan':
        return '🏔️';
      case 'vila mewah':
        return '✨';
      case 'vila keluarga':
        return '👨‍👩‍👧‍👦';
      case 'vila romantis':
        return '💕';
      case 'vila modern':
        return '🏢';
      case 'vila tradisional':
        return '🏛️';
      default:
        return '🏡';
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 15),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}