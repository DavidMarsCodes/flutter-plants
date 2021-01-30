import 'package:chat/models/plant.dart';
import 'package:chat/pages/plant_cover_image.dart';
import 'package:chat/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:ui' as ui;

class PlantPage extends StatefulWidget {
  PlantPage(
      {this.isUserAuth,
      this.isUserEdit = false,
      @required this.plant,
      this.isEmpty = false,
      this.image});
  final bool isUserAuth;
  final bool isUserEdit;
  final Plant plant;
  final bool isEmpty;

  final ui.Image image;

  @override
  _PlantPageState createState() => _PlantPageState();
}

class _PlantPageState extends State<PlantPage> {
  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;

    final size = MediaQuery.of(context).size;
    final _profileCardHeight = size.height / 3;
    return SizedBox.expand(
      child: Container(
        height: _profileCardHeight,
        child: PlantCard(
            image: widget.image,
            isEmpty: widget.isEmpty,
            plant: widget.plant,
            plantColor: currentTheme.scaffoldBackgroundColor),
      ),
    );
  }
}
