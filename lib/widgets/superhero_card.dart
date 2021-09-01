import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/model/alignment_info.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/resources/superheroes_images.dart';

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
            _AvatarWidget(superheroInfo: superheroInfo),
            SizedBox(width: 12),
            _NameAndRealNameWidget(superheroInfo: superheroInfo),
            if (superheroInfo.alignmentInfo != null)
              AlignmentWidget(
                alignmentInfo: superheroInfo.alignmentInfo!,
              ),
          ],
        ),
      ),
    );
  }
}

class AlignmentWidget extends StatelessWidget {
  final AlignmentInfo alignmentInfo;

  const AlignmentWidget({Key? key, required this.alignmentInfo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 1,
      child: Container(
        width: 70,
        padding: EdgeInsets.symmetric(vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: alignmentInfo.color),
        child: Text(
          alignmentInfo.name.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: SuperheroesColors.white,
          ),
        ),
      ),
    );
  }
}

class _NameAndRealNameWidget extends StatelessWidget {
  const _NameAndRealNameWidget({
    Key? key,
    required this.superheroInfo,
  }) : super(key: key);

  final SuperheroInfo superheroInfo;

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
    );
  }
}

class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget({
    Key? key,
    required this.superheroInfo,
  }) : super(key: key);

  final SuperheroInfo superheroInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      color: Colors.white24,
      child: CachedNetworkImage(
        errorWidget: (context, url, error) => Center(
          child: Image.asset(
            SuperheroesImages.unknown,
            width: 20,
            height: 62,
          ),
        ),
        progressIndicatorBuilder: (context, url, progress) => Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: SuperheroesColors.blue,
              value: progress.progress,
            ),
          ),
        ),
        imageUrl: superheroInfo.imageUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
      ),
    );
  }
}
