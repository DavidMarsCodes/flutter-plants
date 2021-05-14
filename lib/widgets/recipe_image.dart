import 'dart:ui';

import 'package:flutter_plants/models/profiles.dart';
import 'package:flutter_plants/widgets/productProfile_card.dart';
import 'package:flutter/material.dart';

class RecipeImageExpanded extends StatefulWidget {
  const RecipeImageExpanded({
    Key key,
    @required this.width,
    @required this.height,
    @required this.profile,
  }) : super(key: key);

  final Profiles profile;
  final double width;

  final double height;

  @override
  _RecipeImageExpandedState createState() => _RecipeImageExpandedState();
}

class _RecipeImageExpandedState extends State<RecipeImageExpanded> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;

    return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        clipBehavior: Clip.antiAlias,
        child: InteractiveViewer(
            panEnabled: false, // Set it to false to prevent panning.

            minScale: 0.5,
            maxScale: 4,
            child: cachedNetworkImage(widget.profile.getRecipeImg())));
  }
}
