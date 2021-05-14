import 'package:animate_do/animate_do.dart';
import 'package:flutter_plants/models/notification.dart';
import 'package:flutter_plants/models/usuario.dart';
import 'package:flutter_plants/pages/messages.dart';
import 'package:flutter_plants/pages/profile_page.dart';
import 'package:flutter_plants/pages/search_Principal_page.dart';
import 'package:flutter_plants/services/auth_service.dart';
import 'package:flutter_plants/theme/theme.dart';
import 'package:flutter_plants/widgets/avatar_user_chat.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class CustomAppBarHeader extends StatefulWidget {
  final bool showContent;

  @override
  CustomAppBarHeader({this.showContent = true});

  @override
  _CustomAppBarHeaderState createState() => _CustomAppBarHeaderState();
}

class _CustomAppBarHeaderState extends State<CustomAppBarHeader> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentTheme = Provider.of<ThemeChanger>(context);

    final profile = authService.profile;

    final size = MediaQuery.of(context).size;
    final int number = Provider.of<NotificationModel>(context).number;

    return Container(
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: GestureDetector(
              onTap: () {
                {
                  Navigator.push(context, _createRoute());
                }
              },
              child: Container(
                padding: EdgeInsets.all(5.0),
                // margin: EdgeInsets.only(left: 15),
                child: Hero(
                  tag: profile.user.uid,
                  child: Material(
                    type: MaterialType.transparency,
                    child: ImageUserChat(
                      width: 100,
                      height: 100,
                      profile: profile,
                      fontsize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          (widget.showContent)
              ? GestureDetector(
                  onTap: () => showSearch(
                      context: context,
                      delegate: DataSearch(userAuth: profile)),
                  child: Center(
                      child: Container(
                          // color: Colors.black,
                          //  margin: EdgeInsets.only(left: 10, right: 10),
                          width: size.height / 3.0,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xff34EC9C),
                                  Color(0xff1D1D1D),
                                  Color(0xff34EC9C),
                                ]),
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black54,
                                  spreadRadius: -5,
                                  blurRadius: 10,
                                  offset: Offset(0, 5))
                            ],
                          ),
                          child: SearchContent())),
                )
              : IconButton(
                  onPressed: () {
                    Navigator.push(context, _createRouteMessages());
                  },
                  icon: Stack(
                    children: <Widget>[
                      FaIcon(
                        FontAwesomeIcons.commentDots,
                        color: Colors.white54,
                        size: 30,
                      ),
                      Positioned(
                        top: 0.0,
                        right: 4.0,
                        child: BounceInDown(
                          from: 10,
                          animate: (number > 0) ? true : false,
                          child: Bounce(
                            delay: Duration(seconds: 2),
                            from: 15,
                            controller: (controller) =>
                                Provider.of<NotificationModel>(context)
                                    .bounceController = controller,
                            child: Container(
                              child: Text(
                                '$number',
                                style: TextStyle(
                                    color: (currentTheme.customTheme)
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                              alignment: Alignment.center,
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                  color: (currentTheme.customTheme)
                                      ? currentTheme.currentTheme.accentColor
                                      : Colors.black,
                                  shape: BoxShape.circle),
                            ),
                          ),
                        ),
                      )
                    ],
                  )),
        ],
      ),
    );
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        SliverAppBarProfilepPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(-0.5, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

Route _createRouteMessages() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => MessagesPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: Duration(milliseconds: 400),
  );
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
                  color: currentTheme.scaffoldBackgroundColor.withOpacity(0.30),
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
