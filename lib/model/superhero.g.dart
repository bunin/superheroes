// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'superhero.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Superhero _$SuperheroFromJson(Map<String, dynamic> json) {
  return Superhero(
    json['name'] as String,
    Biography.fromJson(json['biography'] as Map<String, dynamic>),
    ServerImage.fromJson(json['image'] as Map<String, dynamic>),
    Powerstats.fromJson(json['powerstats'] as Map<String, dynamic>),
    json['id'] as String,
  );
}

Map<String, dynamic> _$SuperheroToJson(Superhero instance) => <String, dynamic>{
      'name': instance.name,
      'biography': instance.biography.toJson(),
      'image': instance.image.toJson(),
      'powerstats': instance.powerstats.toJson(),
      'id': instance.id,
    };
