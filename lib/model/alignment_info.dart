import 'package:flutter/material.dart';
import 'package:superheroes/resources/superheroes_colors.dart';

class AlignmentInfo {
  final String name;
  final Color color;

  const AlignmentInfo._(this.name, this.color);

  static const bad = AlignmentInfo._("bad", SuperheroesColors.red);
  static const good = AlignmentInfo._("good", SuperheroesColors.green);
  static const neutral = AlignmentInfo._("neutral", SuperheroesColors.grey);

  static AlignmentInfo? fromAlignment(final String alignment) {
    switch (alignment) {
      case "bad":
        return bad;
      case "good":
        return good;
      case "neutral":
        return neutral;
      default:
        return null;
    }
  }
}
