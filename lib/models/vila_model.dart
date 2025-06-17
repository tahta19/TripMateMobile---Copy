import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'vila_model.g.dart';

@HiveType(typeId: 11) // Gunakan typeId yang belum digunakan
class VilaModel extends HiveObject {
  @HiveField(0)
  final String nama;

  @HiveField(1)
  final String deskripsi;

  @HiveField(2)
  final String lokasi;

  @HiveField(3)
  final String lokasiDetail;

  @HiveField(4)
  final int hargaPerMalam;

  @HiveField(5)
  final double rating;

  @HiveField(6)
  final int jumlahReview;

  @HiveField(7)
  final String fasilitas;

  @HiveField(8)
  final int jumlahKamar;

  @HiveField(9)
  final int kapasitas;

  @HiveField(10)
  final String imageBase64;

  @HiveField(11)
  final String checkIn;

  @HiveField(12)
  final String checkOut;

  @HiveField(13)
  final String tipeVila;

  @HiveField(14)
  final bool tersediaWifi;

  @HiveField(15)
  final bool tersediaKolam;

  @HiveField(16)
  final bool tersediaParkir;

  VilaModel({
    required this.nama,
    required this.deskripsi,
    required this.lokasi,
    required this.lokasiDetail,
    required this.hargaPerMalam,
    required this.rating,
    required this.jumlahReview,
    required this.fasilitas,
    required this.jumlahKamar,
    required this.kapasitas,
    required this.imageBase64,
    required this.checkIn,
    required this.checkOut,
    required this.tipeVila,
    this.tersediaWifi = false,
    this.tersediaKolam = false,
    this.tersediaParkir = false,
  });

  // Getter untuk format harga
  String get formattedHarga {
    final formatter = NumberFormat("#,###", "id_ID");
    return "Rp ${formatter.format(hargaPerMalam)}";
  }

  // Getter untuk format rating
  String get formattedRating {
    return rating.toStringAsFixed(1);
  }

  // Getter untuk fasilitas utama
  List<String> get fasilitasUtama {
    List<String> facilities = [];
    if (tersediaWifi) facilities.add('WiFi');
    if (tersediaKolam) facilities.add('Kolam Renang');
    if (tersediaParkir) facilities.add('Parkir');
    return facilities;
  }

  // Getter untuk jam operasional
  String get jamOperasional {
    return 'Check-in: $checkIn | Check-out: $checkOut';
  }

  // Getter untuk info kapasitas
  String get infoKapasitas {
    return '$jumlahKamar kamar • $kapasitas tamu';
  }
}

@HiveType(typeId: 8)
class VilaOptionsModel extends HiveObject {
  @HiveField(0)
  final List<String> tipeVila;

  @HiveField(1)
  final List<String> lokasi;

  @HiveField(2)
  final List<String> fasilitasTambahan;

  VilaOptionsModel({
    required this.tipeVila,
    required this.lokasi,
    required this.fasilitasTambahan,
  });
}