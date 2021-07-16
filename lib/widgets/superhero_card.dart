import 'package:flutter/material.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/resources/superheroes_colors.dart';

class SuperheroCard extends StatelessWidget {
  final SuperheroInfo superheroInfo;
  final VoidCallback onTap;

  const SuperheroCard({
    Key? key,
    required this.superheroInfo,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: SuperheroesColors.indigo,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Image.network(
              superheroInfo.imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    superheroInfo.name.toUpperCase(),
                    style: TextStyle(
                      color: SuperheroesColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    superheroInfo.realName,
                    style: TextStyle(
                      color: SuperheroesColors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
