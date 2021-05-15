import 'package:leafety/bloc/profile_bloc.dart';
import 'package:leafety/bloc/provider.dart';
import 'package:leafety/helpers/mostrar_alerta.dart';
import 'package:leafety/models/profiles.dart';
import 'package:leafety/pages/profile_page.dart';
import 'package:leafety/services/auth_service.dart';
import 'package:leafety/services/socket_service.dart';
import 'package:leafety/shared_preferences/auth_storage.dart';
import 'package:leafety/theme/theme.dart';
import 'package:leafety/widgets/button_gold.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

//final Color darkBlue = Color.fromARGB(255, 18, 32, 47);

class FormNewProductPage extends StatefulWidget {
  @override
  FormNewProductPageState createState() => FormNewProductPageState();
}

class FormNewProductPageState extends State<FormNewProductPage> {
  Profiles profile;

  final prefs = new AuthUserPreferences();

  final usernameCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final aboutCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final lastName = TextEditingController();

  bool isUsernameChange = false;
  bool isNameChange = false;
  bool isAboutChange = false;
  bool isEmailChange = false;
  bool isPassChange = false;

  @override
  void initState() {
    final authService = Provider.of<AuthService>(context, listen: false);
    profile = authService.profile;

    usernameCtrl.text = profile.user.username;
    nameCtrl.text = profile.name;
    aboutCtrl.text = profile.name;

    emailCtrl.text = profile.user.email;
    lastName.text = profile.lastName;

    usernameCtrl.addListener(() {
      //print('${usernameCtrl.text}');

      setState(() {
        if (usernameCtrl.text != profile.user.username)
          this.isUsernameChange = true;
        else
          this.isUsernameChange = false;
      });
    });
    nameCtrl.addListener(() {
      // print('${nameCtrl.text}');
      setState(() {
        if (profile.name != nameCtrl.text)
          this.isNameChange = true;
        else
          this.isNameChange = false;
      });
    });
    nameCtrl.addListener(() {
      // print('${nameCtrl.text}');
      setState(() {
        if (profile.name != nameCtrl.text)
          this.isAboutChange = true;
        else
          this.isAboutChange = false;
      });
    });
    emailCtrl.addListener(() {
      //print('${emailCtrl.text}');
      setState(() {
        if (profile.user.email != emailCtrl.text)
          this.isEmailChange = true;
        else
          this.isEmailChange = false;
      });
    });
    passCtrl.addListener(() {
      // print('${passCtrl.text}');
      setState(() {
        if (passCtrl.text.length >= 6)
          this.isPassChange = true;
        else
          this.isPassChange = false;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    usernameCtrl.dispose();
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    lastName.dispose();
    aboutCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;
    final authService = Provider.of<AuthService>(context);

    final bloc = CustomProvider.profileBlocIn(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          _createButton(bloc, this.isUsernameChange, this.isEmailChange,
              this.isNameChange, this.isPassChange),
        ],
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: currentTheme.accentColor,
          ),
          iconSize: 30,
          onPressed: () =>
              //  Navigator.pushReplacement(context, createRouteProfile()),
              Navigator.pop(context),
          color: Colors.white,
        ),
        title: Text('New product'),
      ),
      body: NotificationListener<ScrollEndNotification>(
        onNotification: (_) {
          //  _snapAppbar();
          // if (_scrollController.offset >= 250) {}
          return false;
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              // controller: _scrollController,
              slivers: <Widget>[
                SliverFixedExtentList(
                  itemExtent: size.height / 3.7,
                  delegate: SliverChildListDelegate(
                    [],
                  ),
                ),
                SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                      child: Column(
                        children: <Widget>[
                          _createName(bloc, nameCtrl),
                          SizedBox(
                            height: 10,
                          ),
                          _createUsername(bloc, usernameCtrl),
                          SizedBox(
                            height: 10,
                          ),

                          _createAbout(bloc, aboutCtrl),
                          SizedBox(
                            height: 10,
                          ),
                          // _createLastName(bloc),
                          _createEmail(bloc, emailCtrl),
                          SizedBox(
                            height: 10,
                          ),
                          _createPassword(bloc, passCtrl),
                          SizedBox(
                            height: 30,
                          ),

                          SizedBox(
                            height: 50,
                          ),
                          ButtonLogout(
                            textColor: currentTheme.secondaryHeaderColor,
                            color: currentTheme.scaffoldBackgroundColor,
                            text: 'Log out',
                            onPressed: authService.authenticated
                                ? null
                                : () async {
                                    final socketService =
                                        Provider.of<SocketService>(context,
                                            listen: false);

                                    socketService.disconnect();
                                    Navigator.pushReplacementNamed(
                                        context, 'login');
                                    logout();
                                  },
                          ),
                        ],
                      ),
                    )),
              ]),
        ),
      ),
    );
  }

  void logout() {
    prefs.setToken = '';
    AuthService.signOut();
  }

  Widget _createButton(ProfileBloc bloc, bool isUsernameChange,
      bool isEmailChange, bool isNameChange, bool isPassChange) {
    return StreamBuilder(
      stream: bloc.formValidStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // final authService = Provider.of<AuthService>(context);
        final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;

        final isControllerChange =
            isUsernameChange || isEmailChange || isNameChange || isPassChange;

        final isInvalid = snapshot.hasError;

        return GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Text(
                  'Crear',
                  style: TextStyle(
                      color: isControllerChange && !isInvalid
                          ? currentTheme.accentColor
                          : Colors.white.withOpacity(0.30),
                      fontSize: 15),
                ),
              ),
            ),
            onTap: isControllerChange && !isInvalid
                ? () => {
                      FocusScope.of(context).unfocus(),
                      _editProfile(bloc, context)
                    }
                : null);
      },
    );
  }

  Widget _createEmail(ProfileBloc bloc, TextEditingController emailCtl) {
    return StreamBuilder(
      stream: bloc.emailStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            controller: emailCtl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                // icon: Icon(Icons.alternate_email),
                //  fillColor: currentTheme.accentColor,
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.yellow, width: 2.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                hintText: '',
                labelText: 'Email',
                errorText: snapshot.error),
            onChanged: bloc.changeEmail,
          ),
        );
      },
    );
  }

  Widget _createUsername(ProfileBloc bloc, TextEditingController usernameCtrl) {
    return StreamBuilder(
      stream: bloc.usernameSteam,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            controller: usernameCtrl,
            //  keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                // icon: Icon(Icons.perm_identity),
                //  fillColor: currentTheme.accentColor,
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.yellow, width: 2.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                hintText: '',
                labelText: 'Username',
                // counterText: snapshot.data,
                errorText: snapshot.error),
            onChanged: bloc.changeUsername,
          ),
        );
      },
    );
  }

  Widget _createName(ProfileBloc bloc, TextEditingController nameCtrl) {
    return StreamBuilder(
      stream: bloc.nameStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            controller: nameCtrl,
            //  keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                // icon: Icon(Icons.perm_identity),
                //  fillColor: currentTheme.accentColor,
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.yellow, width: 2.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                hintText: '',
                labelText: 'Name',
                //counterText: snapshot.data,
                errorText: snapshot.error),
            onChanged: bloc.changeName,
          ),
        );
      },
    );
  }

  Widget _createAbout(ProfileBloc bloc, TextEditingController aboutCtrl) {
    return StreamBuilder(
      stream: bloc.nameStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            controller: nameCtrl,
            //  keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                // icon: Icon(Icons.perm_identity),
                //  fillColor: currentTheme.accentColor,
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.yellow, width: 2.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                hintText: '',
                labelText: 'About',
                //counterText: snapshot.data,
                errorText: snapshot.error),
            onChanged: bloc.changeName,
          ),
        );
      },
    );
  }

  Widget _createPassword(ProfileBloc bloc, TextEditingController passCtrl) {
    return StreamBuilder(
      stream: bloc.passwordStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            controller: passCtrl,
            obscureText: true,
            decoration: InputDecoration(
                //  icon: Icon(Icons.lock_outline),
                //  fillColor: currentTheme.accentColor,
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.yellow, width: 2.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                hintText: '',
                labelText: 'Password',
                counterText: snapshot.data,
                errorText: snapshot.error),
            onChanged: bloc.changePassword,
          ),
        );
      },
    );
  }

  _editProfile(ProfileBloc bloc, BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final socketService = Provider.of<SocketService>(context, listen: false);

    final profile = authService.profile;

    print('================');
    print('name: ${bloc.name}');
    print('Password: ${bloc.password}');
    print('email: ${bloc.email}');
    print('username: ${bloc.username}');
    print('================');

    final username =
        (bloc.username == null) ? profile.user.username : bloc.username.trim();

    final name = (bloc.name == null) ? profile.name : bloc.name.trim();

    final email = (bloc.email == null) ? profile.user.email : bloc.email.trim();

    final password = (bloc.password == null) ? '' : bloc.password.trim();

    final about = (bloc.about == null) ? '' : bloc.about.trim();

    final editProfileOk = await authService.editProfile(
        profile.user.uid, username, about, name, email, password);

    if (editProfileOk != null) {
      if (editProfileOk == true) {
        socketService.connect();

        Navigator.push(context, createRoute());
      } else {
        mostrarAlerta(context, 'Error', editProfileOk);
      }
    } else {
      mostrarAlerta(
          context, 'Error del servidor', 'lo sentimos, Intentelo mas tarde');
    }
    //Navigator.pushReplacementNamed(context, '');
  }
}

Route createRoute() {
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
