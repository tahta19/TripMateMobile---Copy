// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vila_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VilaModelAdapter extends TypeAdapter<VilaModel> {
  @override
  final int typeId = 11;

  @override
  VilaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VilaModel(
      nama: fields[0] as String,
      deskripsi: fields[1] as String,
      lokasi: fields[2] as String,
      lokasiDetail: fields[3] as String,
      hargaPerMalam: fields[4] as int,
      rating: fields[5] as double,
      jumlahReview: fields[6] as int,
      fasilitas: fields[7] as String,
      jumlahKamar: fields[8] as int,
      kapasitas: fields[9] as int,
      imageBase64: fields[10] as String,
      checkIn: fields[11] as String,
      checkOut: fields[12] as String,
      tipeVila: fields[13] as String,
      tersediaWifi: fields[14] as bool,
      tersediaKolam: fields[15] as bool,
      tersediaParkir: fields[16] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, VilaModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.nama)
      ..writeByte(1)
      ..write(obj.deskripsi)
      ..writeByte(2)
      ..write(obj.lokasi)
      ..writeByte(3)
      ..write(obj.lokasiDetail)
      ..writeByte(4)
      ..write(obj.hargaPerMalam)
      ..writeByte(5)
      ..write(obj.rating)
      ..writeByte(6)
      ..write(obj.jumlahReview)
      ..writeByte(7)
      ..write(obj.fasilitas)
      ..writeByte(8)
      ..write(obj.jumlahKamar)
      ..writeByte(9)
      ..write(obj.kapasitas)
      ..writeByte(10)
      ..write(obj.imageBase64)
      ..writeByte(11)
      ..write(obj.checkIn)
      ..writeByte(12)
      ..write(obj.checkOut)
      ..writeByte(13)
      ..write(obj.tipeVila)
      ..writeByte(14)
      ..write(obj.tersediaWifi)
      ..writeByte(15)
      ..write(obj.tersediaKolam)
      ..writeByte(16)
      ..write(obj.tersediaParkir);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VilaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VilaOptionsModelAdapter extends TypeAdapter<VilaOptionsModel> {
  @override
  final int typeId = 8;

  @override
  VilaOptionsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VilaOptionsModel(
      tipeVila: (fields[0] as List).cast<String>(),
      lokasi: (fields[1] as List).cast<String>(),
      fasilitasTambahan: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, VilaOptionsModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.tipeVila)
      ..writeByte(1)
      ..write(obj.lokasi)
      ..writeByte(2)
      ..write(obj.fasilitasTambahan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VilaOptionsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
