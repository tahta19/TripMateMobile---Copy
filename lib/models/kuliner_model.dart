import 'package:hive/hive.dart';

part 'kuliner_model.g.dart';

@HiveType(typeId: 10) // Pastikan typeId unik
class KulinerModel extends HiveObject {
  @HiveField(0)
  String nama;

  @HiveField(1)
  String deskripsi;

  @HiveField(2)
  String kategori; // BBQ & Grill, Indonesian, Chinese, dll

  @HiveField(3)
  String lokasi; // Surabaya, Bali, Jogja

  @HiveField(4)
  String lokasiDetail;

  @HiveField(5)
  double rating;

  @HiveField(6)
  int jumlahReview;

  @HiveField(7)
  int hargaMulaiDari;

  @HiveField(8)
  String imageBase64;
  
  @HiveField(9)
  String jamBuka;
  
  @HiveField(10)
  String jamTutup;

  KulinerModel({
    required this.nama,
    required this.deskripsi,
    required this.kategori,
    required this.lokasi,
    required this.lokasiDetail,
    required this.rating,
    required this.jumlahReview,
    required this.hargaMulaiDari,
    required this.imageBase64,
    this.jamBuka = '10:00',
    this.jamTutup = '22:00',
  });

  // Getter untuk mendapatkan icon berdasarkan kategori
  String get kategoriIcon {
    switch (kategori.toLowerCase()) {
      case 'bbq & grill':
        return '🍖';
      case 'indonesian':
        return '🍛';
      case 'chinese':
        return '🥢';
      case 'western':
        return '🍔';
      case 'seafood':
        return '🦐';
      case 'dessert':
        return '🍰';
      default:
        return '🍽️';
    }
  }

  // Getter untuk format harga
  String get formattedHarga {
    return 'Rp ${hargaMulaiDari.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  // Getter untuk format rating
  String get formattedRating {
    return rating.toStringAsFixed(1);
  }
  
  // Getter untuk jam operasional
  String get jamOperasional {
    return '$jamBuka - $jamTutup WIB';
  }

  @override
  String toString() {
    return 'KulinerModel(nama: $nama, kategori: $kategori, lokasi: $lokasi, rating: $rating, harga: $hargaMulaiDari)';
  }
}
