import 'package:leafety/bloc/dispensary_bloc.dart';
import 'package:leafety/models/profiles.dart';
import 'package:leafety/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'profile_card.dart';

import 'dart:ui' as ui;

class ProfilePage extends StatefulWidget {
  ProfilePage(
      {this.isUserAuth,
      this.isUserEdit = false,
      @required this.profile,
      this.loading = false,
      this.isEmpty = false,
      this.image,
      @required this.productsDispensaryBloc});
  final bool isUserAuth;
  final bool isUserEdit;
  final Profiles profile;
  final bool isEmpty;
  final loading;

  final ui.Image image;
  final ProductDispensaryBloc productsDispensaryBloc;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;

    return SizedBox(
      height: 100,
      child: Container(
        color: currentTheme.scaffoldBackgroundColor,
        child: ProfileCard(
            productsDispensaryBloc: widget.productsDispensaryBloc,
            loading: widget.loading,
            image: widget.image,
            isEmpty: widget.isEmpty,
            isUserAuth: widget.isUserAuth,
            isUserEdit: widget.isUserEdit,
            profile: widget.profile,
            profileColor: currentTheme.scaffoldBackgroundColor),
      ),
    );
  }
}
