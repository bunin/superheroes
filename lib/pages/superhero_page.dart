import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:superheroes/blocs/superhero_bloc.dart';
import 'package:superheroes/model/alignment_info.dart';
import 'package:superheroes/model/biography.dart';
import 'package:superheroes/model/powerstats.dart';
import 'package:superheroes/model/superhero.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/resources/superheroes_icons.dart';
import 'package:superheroes/resources/superheroes_images.dart';

class SuperheroPage extends StatefulWidget {
  final http.Client? client;
  final String id;

  SuperheroPage({Key? key, this.client, required this.id}) : super(key: key);

  @override
  _SuperheroPageState createState() => _SuperheroPageState();
}

class _SuperheroPageState extends State<SuperheroPage> {
  late SuperheroBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = SuperheroBloc(client: widget.client, id: widget.id);
  }

  @override
  Widget build(BuildContext context) {
    print("_SuperheroPageState build");
    return Provider.value(
      value: bloc,
      child: StreamBuilder<SuperheroPageState>(
          stream: bloc.observeSuperheroPageState(),
          builder: (context, snapshot) {
            print("_SuperheroPageState.build.StreamBuilder $snapshot");
            return Scaffold(
              backgroundColor: SuperheroesColors.background,
              appBar: (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data! == SuperheroPageState.loaded)
                  ? null
                  : AppBar(
                      primary: true,
                      automaticallyImplyLeading: true,
                    ),
              body: SuperheroPageContent(),
            );
          }),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class SuperheroPageContent extends StatelessWidget {
  const SuperheroPageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<SuperheroBloc>(context, listen: false);

    return StreamBuilder<Superhero>(
        stream: bloc.observeSuperhero(),
        builder: (context, snapshot) {
          return (!snapshot.hasData || snapshot.data == null)
              ? const SizedBox.shrink()
              : CustomScrollView(
                  scrollBehavior: ScrollBehavior().copyWith(
                    physics: BouncingScrollPhysics(
                      parent: RangeMaintainingScrollPhysics(),
                    ),
                  ),
                  slivers: [
                    SuperheroAppBar(superhero: snapshot.data!),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          if (snapshot.data!.powerstats.isNotNull())
                            PowerstatsWidget(
                                powerstats: snapshot.data!.powerstats),
                          BiographyWidget(biography: snapshot.data!.biography),
                        ],
                      ),
                    ),
                  ],
                );
        });
  }
}

class SuperheroAppBar extends StatelessWidget {
  const SuperheroAppBar({
    Key? key,
    required this.superhero,
  }) : super(key: key);

  final Superhero superhero;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      primary: true,
      stretch: true,
      pinned: true,
      floating: true,
      brightness: Brightness.dark,
      actions: [
        FavoriteButton(),
      ],
      expandedHeight: 348,
      backgroundColor: SuperheroesColors.background,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        stretchModes: [StretchMode.zoomBackground],
        title: Text(
          superhero.name,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: SuperheroesColors.white,
          ),
        ),
        centerTitle: true,
        background: CachedNetworkImage(
          imageUrl: superhero.image.url,
          fit: BoxFit.cover,
          placeholder: (context, url) => ColoredBox(
            color: SuperheroesColors.indigo,
            child: SizedBox.expand(),
          ),
          errorWidget: (context, url, error) => ColoredBox(
            color: SuperheroesColors.indigo,
            child: SizedBox(
              width: 85,
              height: 264,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 32, // ??????
                ),
                child: Image.asset(
                  SuperheroesImages.unknownBig,
                  width: 85,
                  height: 264,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FavoriteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<SuperheroBloc>(context, listen: false);
    return StreamBuilder<bool>(
        stream: bloc.observeIsFavorite(),
        initialData: false,
        builder: (context, snapshot) {
          final favorite =
              snapshot.hasData && snapshot.data != null && snapshot.data!;
          return GestureDetector(
            onTap: favorite ? bloc.removeFromFavorites : bloc.addToFavorite,
            child: Container(
              height: 52,
              width: 52,
              alignment: Alignment.center,
              child: Image.asset(
                favorite
                    ? SuperheroesIcons.starFilled
                    : SuperheroesIcons.starEmpty,
                width: 32,
                height: 32,
              ),
            ),
          );
        });
  }
}

class PowerstatsWidget extends StatelessWidget {
  final Powerstats powerstats;

  const PowerstatsWidget({Key? key, required this.powerstats})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Text(
            'Powerstats'.toUpperCase(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: SuperheroesColors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: Center(
                child: PowerstatWidget(
                  name: "Intelligence",
                  value: powerstats.intelligencePercent,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: PowerstatWidget(
                  name: "Strength",
                  value: powerstats.strengthPercent,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: PowerstatWidget(
                  name: "Speed",
                  value: powerstats.speedPercent,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: Center(
                child: PowerstatWidget(
                  name: "Durability",
                  value: powerstats.durabilityPercent,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: PowerstatWidget(
                  name: "Power",
                  value: powerstats.powerPercent,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: PowerstatWidget(
                  name: "Combat",
                  value: powerstats.combatPercent,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        const SizedBox(height: 36),
      ],
    );
  }
}

class PowerstatWidget extends StatelessWidget {
  final String name;
  final double value;

  const PowerstatWidget({
    Key? key,
    required this.name,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ArcWidget(value: value, color: calculateColorByValue()),
        Padding(
          padding: const EdgeInsets.only(top: 17),
          child: Text(
            (value * 100).toInt().toString(),
            style: TextStyle(
              color: calculateColorByValue(),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 44),
          child: Text(
            name.toUpperCase(),
            style: TextStyle(
              color: SuperheroesColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Color calculateColorByValue() {
    if (value <= 0.5) {
      return Color.lerp(Colors.red, Colors.orangeAccent, value * 2)!;
    }
    return Color.lerp(Colors.orangeAccent, Colors.green, (value - 0.5) * 2)!;
  }
}

class ArcWidget extends StatelessWidget {
  final double value;
  final Color color;

  const ArcWidget({
    Key? key,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ArcCustomPainter(value, color),
      size: const Size(66, 33),
    );
  }
}

class ArcCustomPainter extends CustomPainter {
  final double value;
  final Color color;

  ArcCustomPainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    if (value < 1) {
      final bgPaint = Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 6;
      canvas.drawArc(rect, pi, pi, false, bgPaint);
    }
    if (value > 0) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 6;
      canvas.drawArc(rect, pi, value * pi, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      (oldDelegate is ArcCustomPainter)
          ? (oldDelegate.value != value || oldDelegate.color != color)
          : true;
}

class BiographyWidget extends StatelessWidget {
  final Biography biography;

  const BiographyWidget({
    Key? key,
    required this.biography,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ai = AlignmentInfo.fromAlignment(biography.alignment);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: SuperheroesColors.indigo,
      ),
      width: Size.infinite.width,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    "Bio".toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: SuperheroesColors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Full name".toUpperCase(),
                  style: TextStyle(
                    color: SuperheroesColors.subtitle,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 4),
                Text(
                  biography.fullName,
                  style: TextStyle(
                    color: SuperheroesColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 20),
                Text(
                  "Aliases".toUpperCase(),
                  style: TextStyle(
                    color: SuperheroesColors.subtitle,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 4),
                Text(
                  biography.aliases.join(", "),
                  style: TextStyle(
                    color: SuperheroesColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 20),
                Text(
                  "Place of birth".toUpperCase(),
                  style: TextStyle(
                    color: SuperheroesColors.subtitle,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 4),
                Text(
                  biography.placeOfBirth,
                  style: TextStyle(
                    color: SuperheroesColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: RotatedBox(
              quarterTurns: 1,
              child: Container(
                width: 70,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ai!.color,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  biography.alignment.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    color: SuperheroesColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
