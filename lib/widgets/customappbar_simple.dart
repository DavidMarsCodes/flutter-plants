import 'package:flutter_plants/models/usuario.dart';

import 'package:flutter_plants/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBarSimplePages extends StatefulWidget {
  final bool showContent;
  final String title;

  final Widget action;

  @override
  CustomAppBarSimplePages(
      {this.showContent = true, @required this.title, this.action});

  @override
  _CustomAppBarSimplePagesState createState() =>
      _CustomAppBarSimplePagesState();
}

class _CustomAppBarSimplePagesState extends State<CustomAppBarSimplePages> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeChanger>(context);

    return Container(
      color: (currentTheme.customTheme)
          ? currentTheme.currentTheme.cardColor
          : Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: currentTheme.currentTheme.accentColor,
            ),
            iconSize: 30,
            onPressed: () =>
                //  Navigator.pushReplacement(context, createRouteProfile()),
                Navigator.pop(context),
            color: Colors.white,
          ),
          Container(
            margin: EdgeInsets.only(left: 0),
            child: Text(
              widget.title,
              style: TextStyle(
                  fontSize: 20,
                  color:
                      (currentTheme.customTheme) ? Colors.white : Colors.black),
            ),
          ),
          Container(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.more_vert,
                size: 25,
                color: currentTheme.currentTheme.accentColor,
              )),
        ],
      ),
    );
  }
}

class CustomSliverAppBarHeader extends StatelessWidget {
  CustomSliverAppBarHeader({this.user});
  final User user;
  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;
    final size = MediaQuery.of(context).size;

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Center(
            child: Container(
                margin: EdgeInsets.only(left: 30),
                width: size.height / 3,
                height: 40,
                decoration: BoxDecoration(
                  color: currentTheme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black54,
                        spreadRadius: -5,
                        blurRadius: 10,
                        offset: Offset(0, 5))
                  ],
                ),
                child: SearchContent()),
          ),
          Container(
              padding: EdgeInsets.all(0.0),
              child: Icon(
                Icons.more_vert,
                size: 25,
                color: currentTheme.accentColor,
              )),
        ],
      ),
    );
  }
}

class SearchContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final color = Colors.white.withOpacity(0.60);
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Icon( FontAwesomeIcons.chevronLeft, color: Colors.black54 ),

            Icon(Icons.search, color: color),
            SizedBox(width: 20),
            Container(
                // margin: EdgeInsets.only(top: 0, left: 0),
                child: Text('Buscar',
                    style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.w500))),
          ],
        ));
  }
}

class CustomAppBarIcons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          margin: EdgeInsets.only(top: 0),
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.arrow_drop_down_circle,
                  color: Colors.white,
                ),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                  //globalKey.currentState.openEndDrawer();
                },
              ),
              Spacer(),
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  size: 35,
                  color: Colors.white,
                ),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                  //globalKey.currentState.openEndDrawer();
                },
              ),
            ],
          )),
    );
  }
}
