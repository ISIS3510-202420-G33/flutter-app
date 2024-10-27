// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artwork.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArtworkAdapter extends TypeAdapter<Artwork> {
  @override
  final int typeId = 1;

  @override
  Artwork read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Artwork(
      id: fields[0] as int,
      name: fields[1] as String,
      date: fields[2] as String,
      technique: fields[3] as String,
      dimensions: fields[4] as String,
      interpretation: fields[5] as String,
      advancedInfo: fields[6] as String,
      image: fields[7] as String,
      isPromoted: fields[8] as bool,
      museum: fields[9] as int,
      artist: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Artwork obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.technique)
      ..writeByte(4)
      ..write(obj.dimensions)
      ..writeByte(5)
      ..write(obj.interpretation)
      ..writeByte(6)
      ..write(obj.advancedInfo)
      ..writeByte(7)
      ..write(obj.image)
      ..writeByte(8)
      ..write(obj.isPromoted)
      ..writeByte(9)
      ..write(obj.museum)
      ..writeByte(10)
      ..write(obj.artist);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArtworkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
