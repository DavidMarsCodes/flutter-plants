import 'package:leafety/bloc/plant_bloc.dart';
import 'package:leafety/bloc/provider.dart';
import 'package:leafety/bloc/room_bloc.dart';

import 'package:leafety/helpers/mostrar_alerta.dart';

import 'package:leafety/models/plant.dart';
import 'package:leafety/models/profiles.dart';
import 'package:leafety/models/room.dart';
import 'package:leafety/pages/image_plant_cover.dart';
import 'package:leafety/pages/profile_page.dart';

import 'package:leafety/services/auth_service.dart';
import 'package:leafety/services/aws_service.dart';
import 'package:leafety/services/plant_services.dart';

import 'package:leafety/theme/theme.dart';
import 'package:leafety/widgets/productProfile_card.dart';

import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

//final Color darkBlue = Color.fromARGB(255, 18, 32, 47);

class AddUpdatePlantPage extends StatefulWidget {
  AddUpdatePlantPage({this.plant, this.isEdit = false, this.room});

  final Plant plant;
  final bool isEdit;
  final Room room;

  @override
  AddUpdatePlantPageState createState() => AddUpdatePlantPageState();
}

class AddUpdatePlantPageState extends State<AddUpdatePlantPage> {
  Plant plant;
  final nameCtrl = TextEditingController();

  final descriptionCtrl = TextEditingController();

  final quantityCtrl = TextEditingController();

  final _durationFlorationCtrl = TextEditingController();

  // final potCtrl = TextEditingController();

  var tchCtrl = new MaskedTextController(mask: '00');
  var cbdCtrl = new MaskedTextController(mask: '00');

  var potCtrl = new TextEditingController();

  bool isNameChange = false;
  bool isAboutChange = false;
  bool isQuantityChange = false;

  bool isGerminatedChange = false;
  bool isFlorationChange = false;

  bool isThcChange = false;

  bool isCbdChange = false;
  bool isPotChange = false;
  bool errorRequired = false;

  bool loading = false;

  String dropdownValue = 'Sexo';

  String setDateG;

  DateTime selectedDateG = DateTime.now();

  TextEditingController _dateGController = TextEditingController();

  Future<Null> _selectDateGermina(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDateG,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    if (picked != null)
      setState(() {
        selectedDateG = picked;
        _dateGController.text = DateFormat('dd/MM/yyyy').format(selectedDateG);
      });
  }

  String setDateF;

  DateTime selectedDateF = DateTime.now();

  TextEditingController _dateFController = TextEditingController();

  String optionItemSelected;

  bool isDefault;
  Profiles profile;

  @override
  void initState() {
    final plantService = Provider.of<PlantService>(context, listen: false);
    plant = (widget.isEdit) ? plantService.plant : widget.plant;

    final authService = Provider.of<AuthService>(context, listen: false);

    profile = authService.profile;

    errorRequired = (widget.isEdit) ? false : true;
    nameCtrl.text = widget.plant.name;
    descriptionCtrl.text = widget.plant.description;
    quantityCtrl.text = widget.plant.quantity;

    //  optionItemSelected = (widget.isEdit) ? widget.plant.sexo : null;
    _dateGController.text = widget.plant.germinated;
    _durationFlorationCtrl.text = widget.plant.flowering;

    tchCtrl.text = widget.plant.thc;

    cbdCtrl.text = widget.plant.cbd;
    potCtrl.text = widget.plant.pot;

    plantBloc.imageUpdate.add(true);
    nameCtrl.addListener(() {
      // print('${nameCtrl.text}');
      setState(() {
        if (widget.plant.name != nameCtrl.text)
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
        if (widget.plant.description != descriptionCtrl.text)
          this.isAboutChange = true;
        else
          this.isAboutChange = false;
      });
    });

    quantityCtrl.addListener(() {
      setState(() {
        if (widget.plant.quantity != quantityCtrl.text)
          this.isQuantityChange = true;
        else
          this.isQuantityChange = false;
        if (quantityCtrl.text == "")
          errorRequired = true;
        else
          errorRequired = false;
      });
    });

    tchCtrl.addListener(() {
      setState(() {
        if (widget.plant.thc != tchCtrl.text)
          this.isThcChange = true;
        else
          this.isThcChange = false;
      });
    });

    cbdCtrl.addListener(() {
      setState(() {
        if (widget.plant.cbd != cbdCtrl.text)
          this.isCbdChange = true;
        else
          this.isCbdChange = false;
      });
    });

    _dateGController.addListener(() {
      setState(() {
        if (widget.plant.germinated != _dateGController.text)
          this.isGerminatedChange = true;
        else
          this.isGerminatedChange = false;

        if (_dateGController.text == "")
          errorRequired = true;
        else
          errorRequired = false;
      });
    });

    _durationFlorationCtrl.addListener(() {
      setState(() {
        if (widget.plant.flowering != _durationFlorationCtrl.text)
          this.isFlorationChange = true;
        else
          this.isFlorationChange = false;
        if (_durationFlorationCtrl.text == "")
          errorRequired = true;
        else
          errorRequired = false;
      });
    });

    potCtrl.addListener(() {
      setState(() {
        if (widget.plant.pot != potCtrl.text)
          this.isPotChange = true;
        else
          this.isPotChange = false;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    nameCtrl.dispose();

    descriptionCtrl.dispose();

    quantityCtrl.dispose();

    // plantBloc?.dispose();

    tchCtrl.dispose();
    cbdCtrl.dispose();
    _dateGController.dispose();
    _dateFController.dispose();
    potCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeChanger>(context);
    final isImageUpdate = Provider.of<AwsService>(context).isUploadImagePlant;

    final bloc = CustomProvider.plantBlocIn(context);

    final size = MediaQuery.of(context).size;

    final isControllerChange = isNameChange &&
        isQuantityChange &&
        isGerminatedChange &&
        isFlorationChange &&
        isThcChange &&
        isCbdChange;

    final isControllerChangeEdit = isNameChange ||
        isAboutChange ||
        isQuantityChange ||
        // isSexoChange ||
        isGerminatedChange ||
        isFlorationChange ||
        isThcChange ||
        isCbdChange ||
        isPotChange ||
        isImageUpdate;

    return SafeArea(
      child: Scaffold(
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
            onPressed: () {
              //  Navigator.pushReplacement(context, createRouteProfile()),
              Navigator.pop(context);
            },
            color: Colors.white,
          ),
          title: (widget.isEdit)
              ? Text(
                  'Edit plant',
                  style: TextStyle(
                      color: (currentTheme.customTheme)
                          ? Colors.white
                          : Colors.black),
                )
              : Text(
                  'Create plant',
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
                  SliverFixedExtentList(
                    itemExtent: size.height / 3.7,
                    delegate: SliverChildListDelegate(
                      [
                        StreamBuilder<bool>(
                          stream: plantBloc.imageUpdate.stream,
                          builder: (context, AsyncSnapshot<bool> snapshot) {
                            if (snapshot.hasData) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(PageRouteBuilder(
                                      transitionDuration:
                                          Duration(milliseconds: 200),
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          CoverImagePlantPage(
                                              plant: this.plant,
                                              isEdit: widget.isEdit)));
                                },
                                child: Hero(
                                    tag: widget.plant.coverImage,
                                    child: cachedNetworkImage(
                                      this.plant.getCoverImg(),
                                    )),
                              );
                            } else if (snapshot.hasError) {
                              return _buildErrorWidget(snapshot.error);
                            } else {
                              return buildLoadingWidget();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SliverFillRemaining(
                      hasScrollBody: false,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            _createName(bloc),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            _createQuantity(bloc),
                            SizedBox(
                              height: 20,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode()),
                                  _selectDateGermina(context),
                                },
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    style: TextStyle(
                                      color: (currentTheme.customTheme)
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                                    controller: _dateGController,
                                    keyboardType: TextInputType.datetime,
                                    onSaved: (String val) {
                                      setState(() {
                                        setDateG = val;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: (currentTheme.customTheme)
                                                  ? Colors.white54
                                                  : Colors.black54)),
                                      hintText: 'Germinación *',
                                      hintStyle: TextStyle(
                                        color: (currentTheme.customTheme)
                                            ? Colors.white54
                                            : Colors.black54,
                                      ),
                                      suffixIcon: Icon(
                                        Icons.insert_invitation,
                                        color: (currentTheme.customTheme)
                                            ? Colors.white54
                                            : Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            _createDurationFlora(bloc),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Expanded(child: _createThc(bloc)),
                                SizedBox(
                                  width: 50,
                                ),
                                Expanded(child: _createCbd(bloc)),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            _createPot(bloc),
                            SizedBox(
                              height: 10,
                            ),
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
      ),
    );
  }

  Widget buildLoadingWidget() {
    final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;

    return Container(
        height: 400.0,
        child: Center(
            child: CircularProgressIndicator(
          backgroundColor: currentTheme.accentColor,
        )));
  }

  Widget _buildErrorWidget(String error) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Error occured: $error"),
      ],
    ));
  }

  Widget _createName(PlantBloc bloc) {
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
                labelStyle: TextStyle(
                  color: (currentTheme.customTheme)
                      ? Colors.white54
                      : Colors.black54,
                ),
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

                // icon: Icon(Icons.perm_identity),
                //  fillColor: currentTheme.accentColor,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: currentTheme.currentTheme.accentColor, width: 2.0),
                ),
                hintText: '',
                labelText: 'Nombre  *',
                //counterText: snapshot.data,
                errorText: snapshot.error),
            onChanged: bloc.changeName,
          ),
        );
      },
    );
  }

  Widget _createDescription(PlantBloc bloc) {
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
                labelText: 'Descripción',
                //counterText: snapshot.data,
                errorText: snapshot.error),
            onChanged: bloc.changeDescription,
          ),
        );
      },
    );
  }

  Widget _createQuantity(PlantBloc bloc) {
    return StreamBuilder(
      stream: bloc.quantityStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final currentTheme = Provider.of<ThemeChanger>(context);

        return Container(
          child: TextField(
            style: TextStyle(
              color: (currentTheme.customTheme) ? Colors.white : Colors.black,
            ),
            controller: quantityCtrl,
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(2),
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
                labelText: 'Cantidad *',
                //counterText: snapshot.data,
                errorText: snapshot.error),
            onChanged: bloc.changeQuantity,
          ),
        );
      },
    );
  }

  Widget _createDurationFlora(PlantBloc bloc) {
    return StreamBuilder(
      stream: bloc.floweringStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final currentTheme = Provider.of<ThemeChanger>(context);

        return Container(
          child: TextField(
            style: TextStyle(
              color: (currentTheme.customTheme) ? Colors.white : Colors.black,
            ),
            controller: _durationFlorationCtrl,
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(3),
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
                hintText: 'Semanas',
                labelText: 'Duración de floración *',
                //counterText: snapshot.data,
                errorText: snapshot.error),
            onChanged: bloc.changeFlowering,
          ),
        );
      },
    );
  }

  Widget _createThc(PlantBloc bloc) {
    return StreamBuilder(
      stream: bloc.tchStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final currentTheme = Provider.of<ThemeChanger>(context);

        return Container(
          child: TextField(
            style: TextStyle(
              color: (currentTheme.customTheme) ? Colors.white : Colors.black,
            ),
            controller: tchCtrl,
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(3),
            ],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                suffixIcon: Container(
                    padding: EdgeInsets.only(top: 15),
                    child: Text(
                      '%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: (currentTheme.customTheme)
                            ? Colors.white54
                            : Colors.black54,
                      ),
                    )),
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
                labelText: 'THC *',
                //counterText: snapshot.data,
                errorText: snapshot.error),
            onChanged: bloc.changeThc,
          ),
        );
      },
    );
  }

  Widget _createCbd(PlantBloc bloc) {
    return StreamBuilder(
      stream: bloc.tchStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final currentTheme = Provider.of<ThemeChanger>(context);

        return Container(
          child: TextField(
            style: TextStyle(
              color: (currentTheme.customTheme) ? Colors.white : Colors.black,
            ),
            controller: cbdCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                suffixIcon: Container(
                    padding: EdgeInsets.only(top: 15),
                    child: Text(
                      '%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: (currentTheme.customTheme)
                            ? Colors.white54
                            : Colors.black54,
                      ),
                    )),
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
                labelText: 'CBD *',
                //counterText: snapshot.data,
                errorText: snapshot.error),
            onChanged: bloc.changeCbd,
          ),
        );
      },
    );
  }

  Widget _createPot(PlantBloc bloc) {
    return StreamBuilder(
      stream: bloc.potStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final currentTheme = Provider.of<ThemeChanger>(context);

        return Container(
          child: TextField(
            style: TextStyle(
              color: (currentTheme.customTheme) ? Colors.white : Colors.black,
            ),
            controller: potCtrl,
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(3),
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
                labelText: 'Lt Macetero *',
                //counterText: snapshot.data,
                errorText: snapshot.error),
            onChanged: bloc.changePot,
          ),
        );
      },
    );
  }

  Widget _createButton(
    PlantBloc bloc,
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
                child: Text(
                  (widget.isEdit) ? 'Guardar' : 'Crear',
                  style: TextStyle(
                      color: (isControllerChange && !errorRequired)
                          ? currentTheme.accentColor
                          : Colors.grey,
                      fontSize: 18),
                ),
              ),
            ),
            onTap: isControllerChange && !errorRequired && !loading
                ? () => {
                      setState(() {
                        loading = true;
                      }),
                      FocusScope.of(context).unfocus(),
                      (widget.isEdit) ? _editPlant(bloc) : _createPlant(bloc),
                    }
                : null);
      },
    );
  }

  _createPlant(PlantBloc bloc) async {
    final plantService = Provider.of<PlantService>(context, listen: false);
    final awsService = Provider.of<AwsService>(context, listen: false);

    final room = widget.room.id;
    final authService = Provider.of<AuthService>(context, listen: false);

    final uid = authService.profile.user.uid;

    final name = (bloc.name == null) ? widget.plant.name : bloc.name.trim();
    final description = (descriptionCtrl.text == "")
        ? widget.plant.description
        : bloc.description.trim();

    // final sexo = optionItemSelected;

    final quantity =
        (bloc.quantity == null) ? widget.plant.quantity : bloc.quantity.trim();

    final germinated = _dateGController.text;

    final flowering = _durationFlorationCtrl.text;

    final thc = (bloc.thc == null) ? widget.plant.thc : bloc.thc.trim();

    final cbd = (bloc.cbd == null) ? widget.plant.cbd : bloc.cbd.trim();

    final pot = (bloc.pot == null) ? widget.plant.pot : potCtrl.text.trim();

    final newPlant = Plant(
        name: name,
        description: description,
        // sexo: sexo,
        coverImage: widget.plant.coverImage,
        quantity: quantity,
        germinated: germinated,
        flowering: flowering,
        thc: thc,
        cbd: cbd,
        pot: pot,
        room: room,
        user: uid);

    final createPlantResp = await plantService.createPlant(newPlant);

    if (createPlantResp != null) {
      if (createPlantResp.ok) {
        // widget.plants.add(createPlantResp.plant);
        plantService.plant = createPlantResp.plant;
        // plantBloc.getPlant(createPlantResp.plant);

        roomBloc.getMyRooms(profile.user.uid);

        setState(() {
          loading = false;

          plantBloc.getPlantsByUser(profile.user.uid);

          awsService.isUploadImagePlant = true;
        });
        Navigator.pop(context);
        setState(() {});
      } else {
        setState(() {
          loading = false;
        });
        mostrarAlerta(context, 'Error', createPlantResp.msg);
      }
    } else {
      mostrarAlerta(
          context, 'Error del servidor', 'lo sentimos, Intentelo mas tarde');
    }
    //Navigator.pushReplacementNamed(context, '');
  }

  _editPlant(PlantBloc bloc) async {
    final plantService = Provider.of<PlantService>(context, listen: false);
    final awsService = Provider.of<AwsService>(context, listen: false);

    // final uid = authService.profile.user.uid;

    final name = (bloc.name == null) ? widget.plant.name : bloc.name.trim();
    final description = (descriptionCtrl.text == "")
        ? widget.plant.description
        : descriptionCtrl.text.trim();

    // final sexo = optionItemSelected;

    final quantity =
        (bloc.quantity == null) ? widget.plant.quantity : bloc.quantity.trim();

    final germinated = _dateGController.text;

    final flowering = _durationFlorationCtrl.text;

    final thc = (bloc.thc == null) ? widget.plant.thc : bloc.thc.trim();

    final cbd = (bloc.cbd == null) ? widget.plant.cbd : bloc.cbd.trim();

    final pot = (bloc.pot == null) ? widget.plant.pot : potCtrl.text.trim();

    final editPlant = Plant(
        name: name,
        description: description,
        //   sexo: sexo,
        coverImage: plantService.plant.coverImage,
        quantity: quantity,
        germinated: germinated,
        flowering: flowering,
        thc: thc,
        cbd: cbd,
        pot: pot,
        id: widget.plant.id);

    if (widget.isEdit) {
      final editPlantRes = await plantService.editPlant(editPlant);

      if (editPlantRes != null) {
        if (editPlantRes.ok) {
          // widget.rooms.removeWhere((element) => element.id == editRoomRes.room.id)

          // plantBloc.getPlant(editPlantRes.plant);
          plantBloc.getPlantsByUser(profile.user.uid);

          setState(() {
            loading = false;
            awsService.isUploadImagePlant = true;
            plantService.plant = editPlantRes.plant;
          });
          // room = editRoomRes.room;

          Navigator.pop(context);
        } else {
          setState(() {
            loading = false;
          });
          mostrarAlerta(context, 'Error', editPlantRes.msg);
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
