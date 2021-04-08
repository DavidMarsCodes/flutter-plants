import 'package:chat/pages/onBoarding_page.dart';
import 'package:chat/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chat/services/socket_service.dart';
import 'package:chat/services/auth_service.dart';

import 'package:chat/pages/principal_page.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: checkLoginState(context),
        builder: (context, snapshot) {
          return Center(
            child: _buildLoadingWidget(context),
          );
        },
      ),
    );
  }

  Widget _buildLoadingWidget(context) {
    return Container(
        height: 400.0, child: Center(child: CircularProgressIndicator()));
  }

  Future checkLoginState(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final socketService = Provider.of<SocketService>(context, listen: false);

    final autenticado = await authService.isLoggedIn();

    if (autenticado) {
      socketService.connect();
      Navigator.of(context).push(PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 1000),
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return PrincipalPage();
        },
        transitionsBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child) {
          return Align(
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      ));
    } else {
      Navigator.of(context).push(PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 600),
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return OnBoardingScreen();
        },
        transitionsBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child) {
          return Align(
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      ));
    }
  }
}
