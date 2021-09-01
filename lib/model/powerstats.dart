import 'package:json_annotation/json_annotation.dart';

part 'powerstats.g.dart';

@JsonSerializable()
class Powerstats {
  final String intelligence;
  final String strength;
  final String speed;
  final String durability;
  final String power;
  final String combat;

  Powerstats({
    required this.intelligence,
    required this.strength,
    required this.speed,
    required this.durability,
    required this.power,
    required this.combat,
  });

  factory Powerstats.fromJson(Map<String, dynamic> json) =>
      _$PowerstatsFromJson(json);

  Map<String, dynamic> toJson() => _$PowerstatsToJson(this);

  bool isNotNull() {
    return this.intelligence != "null" &&
        this.strength != "null" &&
        this.speed != "null" &&
        this.durability != "null" &&
        this.power != "null" &&
        this.combat != "null";
  }

  double get intelligencePercent => convertStringToPercent(intelligence);

  double get strengthPercent => convertStringToPercent(strength);

  double get speedPercent => convertStringToPercent(speed);

  double get durabilityPercent => convertStringToPercent(durability);

  double get powerPercent => convertStringToPercent(power);

  double get combatPercent => convertStringToPercent(combat);

  double convertStringToPercent(final String value) {
    final v = int.tryParse(value);
    return v == null ? 0 : v / 100;
  }
}
