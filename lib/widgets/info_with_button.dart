import 'package:flutter/material.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/widgets/action_button.dart';

class InfoWithButton extends StatelessWidget {
  final String title; // — будет отвечать за самый крупный текст
  final String subtitle; // — текст поменьше, капсом
  final String buttonText; // — текст на кнопке
  final String assetImage; // — адрес до картинки
  final double imageHeight; //  — высота картинки
  final double imageWidth; // — ширина картинки
  final double imageTopPadding; // — отступ у картинки сверху, в виджете Stack
  final VoidCallback onTap;

  const InfoWithButton({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.assetImage,
    required this.imageHeight,
    required this.imageWidth,
    required this.imageTopPadding,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  color: SuperheroesColors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: imageTopPadding),
                child: Image.asset(
                  assetImage,
                  width: imageWidth,
                  height: imageHeight,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              color: SuperheroesColors.white,
              fontWeight: FontWeight.w800,
              fontSize: 32,
            ),
          ),
          SizedBox(height: 20),
          Text(
            subtitle.toUpperCase(),
            style: TextStyle(
              color: SuperheroesColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 30),
          ActionButton(text: buttonText.toUpperCase(), onTap: onTap),
        ],
      ),
    );
  }
}
