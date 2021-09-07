import 'package:superheroes/model/biography.dart';
import 'package:superheroes/model/powerstats.dart';
import 'package:superheroes/model/server_image.dart';
import 'package:json_annotation/json_annotation.dart';

part 'superhero.g.dart';

@JsonSerializable()
class Superhero {
  final String name;
  final Biography biography;
  final ServerImage image;
  final Powerstats powerstats;
  final String id;

  Superhero({
    required this.name,
    required this.biography,
    required this.image,
    required this.powerstats,
    required this.id,
  });

  factory Superhero.fromJson(Map<String, dynamic> json) =>
      _$SuperheroFromJson(json);

  Map<String, dynamic> toJson() => _$SuperheroToJson(this);

  @override
  String toString() {
    return 'Superhero{name: $name, biography: $biography, image: $image, powerstats: $powerstats, id: $id}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Superhero &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          biography == other.biography &&
          image == other.image &&
          powerstats == other.powerstats &&
          id == other.id;

  @override
  int get hashCode =>
      name.hashCode ^
      biography.hashCode ^
      image.hashCode ^
      powerstats.hashCode ^
      id.hashCode;
}
