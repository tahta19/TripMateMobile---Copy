import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'vila_model.g.dart';

@HiveType(typeId: 9) // Ubah typeId untuk menghindari konflik
class AreaVilaModel extends HiveObject {
  @HiveField(0)
  final String nama;

  @HiveField(1)
  final double jarakKm;

  @HiveField(2)
  final String iconName;

  AreaVilaModel({
    required this.nama,
    required this.jarakKm,
    required this.iconName,
  });
}

@HiveType(typeId: 7) // Gunakan typeId yang belum digunakan
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
  final List<String> fasilitas;

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
  final List<String> badge;

  @HiveField(15)
  final List<AreaVilaModel> areaVila;

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
    required this.badge,
    required this.areaVila,
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

  // Getter untuk jam operasional
  String get jamOperasional {
    return 'Check-in: $checkIn | Check-out: $checkOut';
  }

  // Getter untuk info kapasitas
  String get infoKapasitas {
    return '$jumlahKamar kamar • $kapasitas tamu';
  }
}

@HiveType(typeId: 10)
class VilaOptionsModel extends HiveObject {
  @HiveField(0)
  final List<String> tipeVila;

  @HiveField(1)
  final List<String> lokasi;

  @HiveField(2)
  final List<String> facilities;

  @HiveField(3)
  final List<String> badge;

  VilaOptionsModel({
    required this.tipeVila,
    required this.lokasi,
    required this.facilities,
    required this.badge,
  });
}