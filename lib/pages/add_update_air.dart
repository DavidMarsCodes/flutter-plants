import 'package:flutter_plants/bloc/air_bloc.dart';
import 'package:flutter_plants/bloc/provider.dart';
import 'package:flutter_plants/bloc/room_bloc.dart';

import 'package:flutter_plants/helpers/mostrar_alerta.dart';
import 'package:flutter_plants/models/air.dart';

import 'package:flutter_plants/models/plant.dart';
import 'package:flutter_plants/models/room.dart';
import 'package:flutter_plants/pages/profile_page.dart';
import 'package:flutter_plants/services/air_service.dart';

import 'package:flutter_plants/services/auth_service.dart';

import 'package:flutter_plants/theme/theme.dart';

import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

//final Color darkBlue = Color.fromARGB(255, 18, 32, 47);

class AddUpdateAirPage extends StatefulWidget {
  AddUpdateAirPage({this.air, this.isEdit = false, this.room});

  final Air air;
  final bool isEdit;
  final Room room;

  @override
  AddUpdateAirPageState createState() => AddUpdateAirPageState();
}

class AddUpdateAirPageState extends State<AddUpdateAirPage> {
  Plant plant;
  final nameCtrl = TextEditingController();

  final descriptionCtrl = TextEditingController();

  final quantityCtrl = TextEditingController();

  final _durationFlorationCtrl = TextEditingController();

  final _wattsCtrl = TextEditingController();

  // final potCtrl = TextEditingController();

  bool isNameChange = false;
  bool isAboutChange = false;

  bool errorRequired = false;
  bool isControllerChangeEdit = false;
  bool loading = false;

  bool isThcChange = false;
  bool isWattsChange = false;

  List<DropdownMenuItem> categories = [
    DropdownMenuItem(
      child: Text('Macho'),
      value: "Macho",
    ),
    DropdownMenuItem(
      child: Text('Hembra'),
      value: "Hembra",
    ),
    DropdownMenuItem(
      child: Text('Automatica'),
      value: "Automatica",
    )
  ];

  bool isDefault;

  @override
  void initState() {
    errorRequired = (widget.isEdit) ? false : true;
    nameCtrl.text = widget.air.name;
    descriptionCtrl.text = widget.air.description;
    _wattsCtrl.text = widget.air.watts;

    //  plantBloc.imageUpdate.add(true);
    nameCtrl.addListener(() {
      // print('${nameCtrl.text}');
      setState(() {
        if (widget.air.name != nameCtrl.text)
          this.isNameChange = true;
        else
          this.isNameChange = false;

        if (nameCtrl.text == "")
          errorRequired = true;
        else
          errorRequired = false;
      });
    });
    descriptionCtrl.addListener(() {
      setState(() {
        if (widget.air.description != descriptionCtrl.text)
          this.isAboutChange = true;
        else
          this.isAboutChange = false;
      });
    });

    _wattsCtrl.addListener(() {
      setState(() {
        if (widget.air.watts != _wattsCtrl.text)
          this.isWattsChange = true;
        else
          this.isWattsChange = false;

        if (_wattsCtrl.text == "")
          errorRequired = true;
        else
          errorRequired = false;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    nameCtrl.dispose();

    descriptionCtrl.dispose();

    quantityCtrl.dispose();

    _wattsCtrl.dispose();
    _durationFlorationCtrl.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeChanger>(context);

    final bloc = CustomProvider.airBlocIn(context);

//    final size = MediaQuery.of(context).size;

    final isControllerChange = isNameChange && isWattsChange;

    final isControllerChangeEdit =
        isNameChange || isWattsChange || isAboutChange;

    return Scaffold(
      backgroundColor: currentTheme.currentTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            (currentTheme.customTheme) ? Colors.black : Colors.white,
        actions: [
          (widget.isEdit)
              ? _createButton(bloc, isControllerChangeEdit)
              : _createButton(bloc, isControllerChange),
        ],
        leading: IconButton(
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
        title: (widget.isEdit)
            ? Text(
                'Editar Aire',
                style: TextStyle(
                    color: (currentTheme.customTheme)
                        ? Colors.white
                        : Colors.black),
              )
            : Text(
                'Nuevo Aire',
                style: TextStyle(
                    color: (currentTheme.customTheme)
                        ? Colors.white
                        : Colors.black),
              ),
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
                SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          _createName(bloc),
                          _createWatts(bloc),
                          _createDescription(bloc),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    )),
              ]),
        ),
      ),
    );
  }

  Widget _createName(AirBloc bloc) {
    return StreamBuilder(
      stream: bloc.nameStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final currentTheme = Provider.of<ThemeChanger>(context);

        return Container(
          child: TextField(
            style: TextStyle(
              color: (currentTheme.customTheme) ? Colors.white : Colors.black,
            ),

            controller: nameCtrl,
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(30),
            ],
            //  keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: (currentTheme.customTheme)
                        ? Colors.white54
                        : Colors.black54,
                  ),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                labelStyle: TextStyle(
                  color: (currentTheme.customTheme)
                      ? Colors.white54
                      : Colors.black54,
                ),
                // icon: Icon(Icons.perm_identity),
                //  fillColor: currentTheme.accentColor,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: currentTheme.currentTheme.accentColor, width: 2.0),
                ),
                hintText: '',
                labelText: 'Tipo/Nombre *',
                //counterText: snapshot.data,
                errorText: snapshot.error),
            onChanged: bloc.changeName,
          ),
        );
      },
    );
  }

  Widget _createDescription(AirBloc bloc) {
    //final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;

    return StreamBuilder(
      stream: bloc.descriptionStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final currentTheme = Provider.of<ThemeChanger>(context);

        return Container(
          child: TextField(
            style: TextStyle(
              color: (currentTheme.customTheme) ? Colors.white : Colors.black,
            ),
            inputFormatters: [
              new LengthLimitingTextInputFormatter(100),
            ],
            controller: descriptionCtrl,
            //  keyboardType: TextInputType.emailAddress,

            maxLines: 2,
            //  keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: (currentTheme.customTheme)
                        ? Colors.white54
                        : Colors.black54,
                  ),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                labelStyle: TextStyle(
                  color: (currentTheme.customTheme)
                      ? Colors.white54
                      : Colors.black54,
                ),
                // icon: Icon(Icons.perm_identity),
                //  fillColor: currentTheme.accentColor,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: currentTheme.currentTheme.accentColor, width: 2.0),
                ),
                hintText: '',
                labelText: 'Descripción *',
                //counterText: snapshot.data,
                errorText: snapshot.error),
            onChanged: bloc.changeDescription,
          ),
        );
      },
    );
  }

  Widget _createWatts(AirBloc bloc) {
    return StreamBuilder(
      stream: bloc.wattsStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final currentTheme = Provider.of<ThemeChanger>(context);

        return Container(
          child: TextField(
            style: TextStyle(
              color: (currentTheme.customTheme) ? Colors.white : Colors.black,
            ),
            controller: _wattsCtrl,
            onTap: () => {
              if (_wattsCtrl.text == "0") _wattsCtrl.text = "",
              setState(() {})
            },
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(5),
            ],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: (currentTheme.customTheme)
                        ? Colors.white54
                        : Colors.black54,
                  ),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                labelStyle: TextStyle(
                  color: (currentTheme.customTheme)
                      ? Colors.white54
                      : Colors.black54,
                ),
                // icon: Icon(Icons.perm_identity),
                //  fillColor: currentTheme.accentColor,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: currentTheme.currentTheme.accentColor, width: 2.0),
                ),
                hintText: '',
                labelText: 'Watts *',
                //counterText: snapshot.data,
                errorText: snapshot.error),
            onChanged: bloc.changeWatts,
          ),
        );
      },
    );
  }

  Widget _createButton(
    AirBloc bloc,
    bool isControllerChange,
  ) {
    return StreamBuilder(
      stream: bloc.formValidStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;

        return GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: (!loading)
                    ? Text(
                        (widget.isEdit) ? 'Guardar' : 'Crear',
                        style: TextStyle(
                            color: (isControllerChange && !errorRequired)
                                ? currentTheme.accentColor
                                : Colors.grey,
                            fontSize: 18),
                      )
                    : _buildLoadingWidget(),
              ),
            ),
            onTap: isControllerChange && !errorRequired && !loading
                ? () => {
                      setState(() {
                        loading = true;
                      }),
                      FocusScope.of(context).unfocus(),
                      (widget.isEdit) ? _editAir(bloc) : _createAir(bloc),
                    }
                : null);
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
        padding: EdgeInsets.only(right: 10),
        height: 400.0,
        child: Center(child: CircularProgressIndicator()));
  }

  _createAir(AirBloc bloc) async {
    final airService = Provider.of<AirService>(context, listen: false);

    final room = widget.room.id;
    final authService = Provider.of<AuthService>(context, listen: false);

    final uid = authService.profile.user.uid;

    final name = (bloc.name == null) ? widget.air.name : bloc.name.trim();
    final description = (descriptionCtrl.text == "")
        ? widget.air.description
        : bloc.description.trim();
    final watts = (bloc.watts == null) ? widget.air.watts : bloc.watts.trim();

    final newAir = Air(
        name: name,
        description: description,
        watts: watts,
        room: room,
        user: uid);

    final createAirResp = await airService.createAir(newAir);

    if (createAirResp != null) {
      if (createAirResp.ok) {
        loading = false;

        roomBloc.getMyRooms(uid);

        Navigator.pop(context);
        setState(() {});
      } else {
        mostrarAlerta(context, 'Error', createAirResp.msg);
      }
    } else {
      mostrarAlerta(
          context, 'Error del servidor', 'lo sentimos, Intentelo mas tarde');
    }
    //Navigator.pushReplacementNamed(context, '');
  }

  _editAir(AirBloc bloc) async {
    final airService = Provider.of<AirService>(context, listen: false);

    // final uid = authService.profile.user.uid;

    final name = (bloc.name == null) ? widget.air.name : bloc.name.trim();
    final description = (descriptionCtrl.text == "")
        ? widget.air.description
        : descriptionCtrl.text.trim();

    final watts = (bloc.watts == null) ? widget.air.watts : bloc.watts.trim();

    final editPlant = Air(
        name: name, description: description, watts: watts, id: widget.air.id);

    if (widget.isEdit) {
      final editRoomRes = await airService.editAir(editPlant);

      if (editRoomRes != null) {
        if (editRoomRes.ok) {
          // widget.rooms.removeWhere((element) => element.id == editRoomRes.room.id)
          //  plantBloc.getPlant(widget.plant);
          setState(() {
            loading = false;
          });
          // room = editRoomRes.room;

          Navigator.pop(context);
        } else {
          mostrarAlerta(context, 'Error', editRoomRes.msg);
        }
      } else {
        mostrarAlerta(
            context, 'Error del servidor', 'lo sentimos, Intentelo mas tarde');
      }
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
