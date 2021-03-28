import 'package:chat/bloc/plant_bloc.dart';
import 'package:chat/models/plant.dart';
import 'package:chat/theme/theme.dart';
import 'package:chat/widgets/productProfile_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../utils/extension.dart';

class CardPlant extends StatefulWidget {
  CardPlant({this.plant, this.isPrincipal = false, this.isSelected = false});

  final Plant plant;
  final bool isPrincipal;

  final bool isSelected;

  @override
  _CardPlantState createState() => _CardPlantState();
}

int countSelect = 0;
List<Plant> platsSelected = [];

class _CardPlantState extends State<CardPlant> {
  bool isSelected = false;

  @override
  void dispose() {
    super.dispose();
    countSelect = 0;
    platsSelected = [];
    plantBloc.plantsSelected.sink.add(platsSelected);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final currentTheme = Provider.of<ThemeChanger>(context);

    //   final productService = Provider.of<PlantService>(context, listen: false);
    final isPlantSelected =
        (platsSelected.contains(widget.plant)) ? true : false;
    return (widget.isSelected)
        ? GestureDetector(
            onTap: () {
              setState(() {
                if (isPlantSelected) {
                  platsSelected.remove(widget.plant);
                  plantBloc.plantsSelected.sink.add(platsSelected);

                  countSelect--;
                  if (countSelect == 0)
                    plantBloc.plantsSelected.sink.add(platsSelected);
                } else {
                  platsSelected.add(widget.plant);
                  countSelect++;
                  plantBloc.plantsSelected.sink.add(platsSelected);
                }

                print(countSelect);
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: (isPlantSelected) ? 0 : 3,
                    blurRadius: (isPlantSelected) ? 0 : 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                border: Border.all(
                  width: (isPlantSelected) ? 3.0 : 0,
                  style: BorderStyle.solid,
                  color: platsSelected.contains(widget.plant)
                      ? currentTheme.currentTheme.accentColor
                      : Colors.transparent,
                ),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.0),
                    topLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0)),
                color: (currentTheme.customTheme)
                    ? currentTheme.currentTheme.cardColor
                    : Colors.white,
              ),
              child: FittedBox(
                child: Row(
                  children: <Widget>[
                    Center(child: plantItem()),
                    Container(
                      width: size.width,
                      height: (!widget.isPrincipal)
                          ? size.height / 1.40
                          : size.height,
                      child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20.0),
                              bottomRight: Radius.circular(15.0)),
                          child: Material(
                              type: MaterialType.transparency,
                              child: (widget.plant.coverImage != "")
                                  ? cachedNetworkImage(
                                      widget.plant.getCoverImg())
                                  : cachedNetworkImage(
                                      'assets/images/empty_image.png'))),
                    ),
                  ],
                ),
              ),
            ),
          )
        : AnimatedContainer(
            duration: Duration(milliseconds: 200),
            decoration: BoxDecoration(
              border: Border.all(
                width: (platsSelected.contains(widget.plant)) ? 3.0 : 0,
                style: BorderStyle.solid,
                color: platsSelected.contains(widget.plant)
                    ? currentTheme.currentTheme.accentColor
                    : Colors.transparent,
              ),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20.0),
                  topLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0)),
              color: (currentTheme.customTheme)
                  ? currentTheme.currentTheme.cardColor
                  : Colors.white,
            ),
            child: FittedBox(
              child: Row(
                children: <Widget>[
                  Center(child: plantItem()),
                  Container(
                    width: size.width,
                    height: (!widget.isPrincipal)
                        ? size.height / 1.40
                        : size.height,
                    child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20.0),
                            bottomRight: Radius.circular(15.0)),
                        child: Material(
                            type: MaterialType.transparency,
                            child: (widget.plant.coverImage != "")
                                ? cachedNetworkImage(widget.plant.getCoverImg())
                                : cachedNetworkImage(
                                    'assets/images/empty_image.png'))),
                  ),
                ],
              ),
            ),
          );
  }

  Widget plantItem() {
    final size = MediaQuery.of(context).size;
    final currentTheme = Provider.of<ThemeChanger>(context);
    final thc = (widget.plant.thc.isEmpty) ? '0' : widget.plant.thc;
    final cbd = (widget.plant.cbd.isEmpty) ? '0' : widget.plant.cbd;

    return Container(
      padding: EdgeInsets.only(left: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              widget.plant.name.capitalize(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize:
                      (widget.isPrincipal) ? size.width / 5.0 : size.width / 10,
                  color: currentTheme.currentTheme.accentColor),
            ),
          ),
          SizedBox(height: 10.0),
          CbdthcRow(
            thc: thc,
            cbd: cbd,
            fontSize: size.width / 15,
          ),
          SizedBox(height: 10.0),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            width: size.width,
            child: Text(
              (widget.plant.description.length > 0)
                  ? widget.plant.description.capitalize()
                  : "Sin descripción",
              overflow: TextOverflow.ellipsis,
              maxLines: 4,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: (widget.isPrincipal)
                      ? size.width / 10
                      : size.width / 12.5,
                  color: Colors.grey),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 0),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                      child: FaIcon(
                    FontAwesomeIcons.seedling,
                    color: (currentTheme.customTheme)
                        ? Colors.white54
                        : Colors.grey,
                    size: size.width / 10,
                  )),
                ),
                SizedBox(
                  width: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    widget.plant.germinated,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: (widget.isPrincipal)
                            ? size.width / 10
                            : size.width / 13,
                        color: (currentTheme.customTheme)
                            ? Colors.white54
                            : Colors.grey),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SexLtRow extends StatelessWidget {
  const SexLtRow(
      {Key key, @required this.pot, @required this.sex, this.fontSize = 10})
      : super(key: key);

  final String pot;
  final String sex;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5.0),
            child: Container(
              padding: EdgeInsets.all(2.5),
              child: Text(
                "Sexo:",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                    color: Colors.white54),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5.0),
            child: Container(
              padding: EdgeInsets.all(5.0),
              child: Text(
                "$sex",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                    color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5.0),
            child: Container(
              padding: EdgeInsets.all(2.5),
              child: Text(
                "Lt:",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                    color: Colors.white54),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5.0),
            child: Container(
              padding: EdgeInsets.all(5.0),
              child: Text(
                "$pot",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                    color: Colors.white),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}

class CbdthcRow extends StatelessWidget {
  const CbdthcRow(
      {Key key, @required this.thc, @required this.cbd, this.fontSize = 10})
      : super(key: key);

  final String thc;
  final String cbd;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          child: Container(
            padding: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: Color(0xffF12937E),
              //color: Theme.of(context).accentColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "THC: $thc %",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                  color: Colors.white),
            ),
          ),
        ),
        SizedBox(
          width: size.width / 10,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5.0),
          child: Container(
            padding: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              //color: Theme.of(context).accentColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "CBD: $cbd %",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                  color: Colors.white),
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
      ],
    );
  }
}

class DateGDurationF extends StatelessWidget {
  const DateGDurationF(
      {Key key,
      @required this.germina,
      @required this.flora,
      this.fontSize = 10})
      : super(key: key);

  final String germina;
  final String flora;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5.0),
              child: Container(
                padding: EdgeInsets.all(2.5),
                child: Text(
                  "Germinación :",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      color: Colors.white54),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5.0),
              child: Container(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  "$germina",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      color: Colors.white),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5.0),
              child: Container(
                padding: EdgeInsets.all(2.5),
                child: Text(
                  "Duración floración :",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      color: Colors.white54),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5.0),
              child: Container(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  "$flora",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}
