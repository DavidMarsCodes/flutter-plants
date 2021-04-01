import 'dart:async';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:animations/animations.dart';
import 'package:chat/bloc/plant_bloc.dart';
import 'package:chat/bloc/room_bloc.dart';
import 'package:chat/models/plant.dart';
import 'package:chat/models/profiles.dart';
import 'package:chat/models/room.dart';
import 'package:chat/models/rooms_response.dart';
import 'package:chat/models/visit.dart';
import 'package:chat/pages/add_update_plant.dart';
import 'package:chat/pages/add_update_visit.dart';
import 'package:chat/pages/chat_page.dart';
import 'package:chat/pages/principal_page.dart';
import 'package:chat/pages/product_detail.dart';
import 'package:chat/pages/room_list_page.dart';
import 'package:chat/providers/plants_provider.dart';
import 'package:chat/providers/visit_provider.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/aws_service.dart';
import 'package:chat/services/plant_services.dart';
import 'package:chat/services/room_services.dart';
import 'package:chat/services/visit_service.dart';
import 'package:chat/theme/theme.dart';
import 'package:chat/widgets/card_product.dart';
import 'package:chat/widgets/carousel_tabs.dart';
import 'package:chat/widgets/productProfile_card.dart';
import 'package:chat/widgets/sliver_appBar_snap.dart';
import 'package:chat/widgets/visit_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import '../utils//extension.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'cover_image_visit.dart';

class PlantDetailPage extends StatefulWidget {
  PlantDetailPage({
    Key key,
    this.title,
    this.plants,
    this.isUserAuth,
    @required this.plant,
  }) : super(key: key);

  final String title;

  final Plant plant;
  final List<Plant> plants;
  final bool isUserAuth;

  @override
  _PlantDetailPageState createState() => new _PlantDetailPageState();
}

class NetworkImageDecoder {
  final NetworkImage image;
  const NetworkImageDecoder({this.image});

  Future<ImageInfo> get imageInfo async {
    final Completer<ImageInfo> completer = Completer();
    image.resolve(ImageConfiguration()).addListener(
          ImageStreamListener(
            (ImageInfo info, bool _) => completer.complete(info),
          ),
        );
    return await completer.future;
  }

  Future<ui.Image> get uiImage async {
    final ImageInfo _info = await imageInfo;
    return _info.image;
  }
}

class Options {
  final int id;
  final String name;
  final String code;

  const Options(this.id, this.name, this.code);
}

class _PlantDetailPageState extends State<PlantDetailPage>
    with TickerProviderStateMixin {
  List<Visit> visits = [];
  ScrollController _scrollController;

  final visitApiProvider = new VisitApiProvider();

  final visitService = VisitService();

  TabController _tabController;

  final plantsApiProvider = new PlantsApiProvider();
  String name = '';

  Future<List<Room>> getRoomsFuture;
  AuthService authService;
  Plant plant;

  Plant plantInit;

  Profiles profile;

  TabController controller;

  final roomService = new RoomService();
  double get maxHeight => 200 + MediaQuery.of(context).padding.top;
  double get minHeight => MediaQuery.of(context).padding.bottom;

  bool isLike = false;

  @override
  void initState() {
    _scrollController = ScrollController()..addListener(() => setState(() {}));
    _tabController = new TabController(vsync: this, length: 1);

    plantBloc.imageUpdate.add(true);

    super.initState();
    //  name = widget.profile.name;
    //   plantBloc.getPlant(widget.plant);

    final authService = Provider.of<AuthService>(context, listen: false);

    profile = authService.profile;

    final plantService = Provider.of<PlantService>(context, listen: false);
    plantService.plant = null;
    //roomBloc.getRooms(widget.profile.user.uid);
  }

  @override
  void dispose() {
    super.dispose();

    _scrollController?.dispose();
    _tabController.dispose();
  }

  bool get _showTitle {
    return _scrollController.hasClients && _scrollController.offset >= 130;
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeChanger>(context);
    final size = MediaQuery.of(context).size;
    final visit = new Visit();

    final visitService = Provider.of<VisitService>(context, listen: false);
    final aws = Provider.of<AwsService>(context, listen: false);

    final plantService = Provider.of<PlantService>(context, listen: false);

    setState(() {
      plant = (plantService.plant != null) ? plantService.plant : widget.plant;
    });

    return Scaffold(
        backgroundColor: currentTheme.currentTheme.scaffoldBackgroundColor,
        // bottomNavigationBar: BottomNavigation(isVisible: _isVisible),
        body: NotificationListener<ScrollEndNotification>(
          onNotification: (_) {
            if (visits.length == 0) _snapAppbar();
            if (_scrollController.offset >= 250) {}
            return false;
          },
          child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  controller: _scrollController,
                  slivers: <Widget>[
                    SliverAppBar(
                      stretch: true,
                      stretchTriggerOffset: 250.0,

                      backgroundColor: _showTitle
                          ? (currentTheme.customTheme)
                              ? Colors.black
                              : Colors.white
                          : currentTheme.currentTheme.scaffoldBackgroundColor,
                      leading: Container(
                          margin: EdgeInsets.only(left: 15),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                            child: CircleAvatar(
                                child: IconButton(
                                    icon: Icon(Icons.arrow_back_ios,
                                        size: 20,
                                        color: (_showTitle)
                                            ? currentTheme
                                                .currentTheme.accentColor
                                            : Colors.white),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                                backgroundColor: _showTitle
                                    ? (currentTheme.customTheme)
                                        ? Colors.black54
                                        : Colors.white54
                                    : Colors.black54),
                          )),

                      actions: [
                        (widget.isUserAuth)
                            ? Container(
                                margin: EdgeInsets.only(left: 0, right: 0),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  child: CircleAvatar(
                                      child: PopupMenuButton<String>(
                                        icon: FaIcon(FontAwesomeIcons.ellipsisV,
                                            size: 20,
                                            color: (_showTitle)
                                                ? currentTheme
                                                    .currentTheme.accentColor
                                                : Colors.white),
                                        onSelected: (String result) {
                                          switch (result) {
                                            case '1':
                                              aws.isUploadImagePlant = false;
                                              visitService.visit = visit;
                                              Navigator.of(context).push(
                                                  createRouteNewVisit(visit,
                                                      widget.plant.id, false));

                                              break;
                                            case '2':
                                              aws.isUploadImagePlant = false;
                                              plantService.plant = plant;
                                              Navigator.of(context).push(
                                                  createRouteEditPlant(
                                                      widget.plant));
                                              break;
                                            case '3':
                                              confirmDelete(
                                                  context,
                                                  'Confirmar',
                                                  'Desea eliminar la Planta y todas sus visitas?',
                                                  plant.id,
                                                  currentTheme
                                                      .currentTheme.cardColor);
                                              break;
                                            default:
                                          }
                                        },
                                        itemBuilder: (BuildContext context) =>
                                            <PopupMenuEntry<String>>[
                                          PopupMenuItem<String>(
                                              value: '1',
                                              child: Row(
                                                children: [
                                                  FaIcon(FontAwesomeIcons.eye,
                                                      size: 20,
                                                      color: currentTheme
                                                          .currentTheme
                                                          .accentColor),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    'Visitar',
                                                    style: TextStyle(
                                                        color: currentTheme
                                                            .currentTheme
                                                            .accentColor),
                                                  ),
                                                ],
                                              )),
                                          PopupMenuItem<String>(
                                              value: '2',
                                              child: Row(
                                                children: [
                                                  FaIcon(
                                                    FontAwesomeIcons.edit,
                                                    color: currentTheme
                                                        .currentTheme
                                                        .accentColor,
                                                    size: 20,
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text('Editar',
                                                      style: TextStyle(
                                                          color: currentTheme
                                                              .currentTheme
                                                              .accentColor)),
                                                ],
                                              )),
                                          PopupMenuItem<String>(
                                            value: '3',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete,
                                                    color: Colors.grey),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text('Eliminar',
                                                    style: TextStyle(
                                                        color: Colors.grey)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: _showTitle
                                          ? (currentTheme.customTheme)
                                              ? Colors.black54
                                              : Colors.white54
                                          : Colors.black54),
                                ))
                            : Container(),
                        (widget.isUserAuth)
                            ? _buildCircleQuantityPlant()
                            : Container(),
                      ],

                      centerTitle: true,
                      pinned: true,

                      expandedHeight: maxHeight,
                      // collapsedHeight: 56.0001,
                      flexibleSpace: FlexibleSpaceBar(
                          stretchModes: [
                            StretchMode.zoomBackground,
                            StretchMode.fadeTitle,
                            // StretchMode.blurBackground
                          ],
                          background: Material(
                            type: MaterialType.transparency,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(0.0),
                                      topRight: Radius.circular(0.0),
                                      bottomRight: Radius.circular(30.0),
                                      bottomLeft: Radius.circular(30.0)),
                                  child:
                                      cachedNetworkImage(plant.getCoverImg()),
                                ),
                                Positioned(
                                  bottom: 0.0,
                                  left: 0.0,
                                  right: 0.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50.0),
                                      gradient: LinearGradient(
                                        colors: [
                                          Color.fromARGB(170, 0, 0, 0),
                                          Color.fromARGB(0, 0, 0, 0)
                                        ],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 30.0, horizontal: 20.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          centerTitle: true,
                          title: Container(
                              //  margin: EdgeInsets.only(left: 0),
                              width: size.height / 5,
                              height: 30,
                              child: Container(
                                child: Center(
                                  child: Text(
                                    plant.name.capitalize(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _showTitle
                                            ? (currentTheme.customTheme)
                                                ? Colors.white
                                                : Colors.black
                                            : Colors.white),
                                  ),
                                ),
                              ))),
                    ),

                    // makeHeaderSpacer(context),
                    makeHeaderInfo(context),
                    // makeHeaderSpacer(context),

                    //   makeHeaderTabs(context),

                    makeListVisits(context)
                  ])),
        ));
  }

  void _snapAppbar() {
    final scrollDistance = maxHeight - minHeight;

    if (_scrollController.offset > 0 &&
        _scrollController.offset < scrollDistance) {
      final double snapOffset =
          _scrollController.offset / scrollDistance > 0.5 ? scrollDistance : 0;

      Future.microtask(() => _scrollController.animateTo(snapOffset,
          duration: Duration(milliseconds: 200), curve: Curves.easeIn));
    }
  }

  SliverList makeListVisits(context) {
    final currentTheme = Provider.of<ThemeChanger>(context);

    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          child: FutureBuilder(
            future: this.visitApiProvider.getVisitPlant(widget.plant.id),
            initialData: null,
            builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
              if (snapshot.hasData) {
                visits = snapshot.data;
                return (visits.length > 0)
                    ? Stack(
                        children: [
                          Container(
                              margin: EdgeInsets.only(top: 0),
                              alignment: Alignment.center,
                              child: Text(
                                  (visits.length == 1) ? 'Visita' : 'Visitas',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: (currentTheme.customTheme)
                                        ? Colors.white54
                                        : Colors.black54,
                                  ))),
                          Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: _buildWidgetVisits(visits)),
                        ],
                      )
                    : Center(
                        child: Container(
                            padding: EdgeInsets.all(50),
                            child: Text('No hay visitas, Agrega una nueva!',
                                style: TextStyle(
                                  color: (currentTheme.customTheme)
                                      ? Colors.white54
                                      : Colors.black54,
                                ))),
                      ); // image is ready
              } else {
                return Container(
                    height: 100.0,
                    child: Center(
                        child: CircularProgressIndicator(
                      color: currentTheme.currentTheme.accentColor,
                    ))); // placeholder
              }
            },
          ),
        ),
      ]),
    );
  }

  _deleteVisit(String id, int index) async {
    final res = await this.visitService.deleteVisit(id);
    if (res) {
      setState(() {
        visits.removeAt(index);
      });
    }
  }

  _deletePlant(
    String id,
  ) async {
    final res = await this.plantsApiProvider.deletePlant(id);
    if (res) {
      setState(() {
        //    widget.plants.removeAt(index);
        roomBloc.getMyRooms(profile.user.uid);
        plantBloc.getPlantsByUser(profile.user.uid);

        Navigator.pop(context);
        Navigator.pop(context);
      });
    }
  }

  SliverList makeVisitCard(context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          child: FutureBuilder(
            future: this.visitApiProvider.getVisitPlant(widget.plant.id),
            initialData: null,
            builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
              if (snapshot.hasData) {
                visits = snapshot.data;
                return (visits.length > 0)
                    ? Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child:
                            _buildWidgetVisits(snapshot.data)) // image is ready
                    : Center(
                        child: Container(
                            padding: EdgeInsets.all(50),
                            child: Text('Sin Plantas, add new')),
                      ); // image is ready
              } else {
                return Container(
                    height: 500.0,
                    child: Center(
                        child: CircularProgressIndicator())); // placeholder
              }
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildWidgetVisits(visits) {
    final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;

    return Container(
      child: SizedBox(
        child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: visits.length,
            itemBuilder: (BuildContext ctxt, int index) {
              final visit = visits[index];

              return Container(
                padding: EdgeInsets.only(bottom: 20),
                child: OpenContainer(
                    closedColor: currentTheme.scaffoldBackgroundColor,
                    openColor: currentTheme.scaffoldBackgroundColor,
                    transitionType: ContainerTransitionType.fade,
                    openShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    closedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    openBuilder: (_, closeContainer) {
                      return (widget.isUserAuth)
                          ? AddUpdateVisitPage(
                              visit: visit,
                              plant: visit.plant,
                              isEdit: true,
                            )
                          : Container(
                              child: CoverImageVisitPage(
                              visit: visit,
                              isUserAuth: false,
                            ));
                    },
                    closedBuilder: (_, openContainer) {
                      return (widget.isUserAuth)
                          ? FadeIn(
                              child: Dismissible(
                                  child: CardVisit(visit: visit),
                                  key: UniqueKey(),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (direction) => {
                                        {_deleteVisit(visit.id, index)}
                                      },
                                  background: Container(
                                    height: 170.0,
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              margin:
                                                  EdgeInsets.only(right: 10),
                                              child: Icon(
                                                Icons.delete,
                                                color: Colors.black,
                                                size: 30,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 12,
                                            ),
                                          ],
                                        )),
                                  )),
                            )
                          : FadeIn(
                              child: CardVisit(visit: visit),
                            );
                    }),
              );
            }),
      ),
    );
  }

  Container _buildCircleQuantityPlant() {
    //final size = MediaQuery.of(context).size;
    final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;
    final quantity = plant.quantity;
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.all(6.0),
      margin: EdgeInsets.only(right: 10, top: 0),
      width: 50,
      height: 50,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        child: CircleAvatar(
            child: Text(
              '$quantity',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            backgroundColor: currentTheme.accentColor),
      ),
    );
  }

  createSelectionNvigator() {
    final currentTheme =
        Provider.of<ThemeChanger>(context, listen: false).currentTheme;
    final size = MediaQuery.of(context).size;
    //final bloc = CustomProvider.roomBlocIn(context);

    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: currentTheme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                      top: 20, left: size.width / 3.0, right: size.width / 3.0),
                  padding: EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Color(0xffEBECF0).withOpacity(0.30),
                    borderRadius: BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(30),
                  child: Text(
                    "Create",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                //_createName(bloc),
                SizedBox(
                  height: 30,
                ),
                //_createDescription(bloc),
                SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverPersistentHeader makeHeaderTabVisit(context) {
    //   final roomModel = Provider.of<Room>(context);

    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverAppBarDelegate(
        minHeight: 70.0,
        maxHeight: 70.0,
        child: StreamBuilder<RoomsResponse>(
          stream: roomBloc.myRooms.stream,
          builder: (context, AsyncSnapshot<RoomsResponse> snapshot) {
            if (snapshot.hasData) {
              return _buildUserWidget(snapshot.data);
            } else if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error);
            } else {
              return _buildLoadingWidget();
            }
          },
        ),
      ),
    );
  }

  SliverPersistentHeader makeProductsCard(context) {
    //   final roomModel = Provider.of<Room>(context);

    return SliverPersistentHeader(
      pinned: false,
      delegate: SliverAppBarDelegate(
        minHeight: 70.0,
        maxHeight: 70.0,
        child: StreamBuilder<RoomsResponse>(
          stream: roomBloc.myRooms.stream,
          builder: (context, AsyncSnapshot<RoomsResponse> snapshot) {
            if (snapshot.hasData) {
              return _buildWidgetProduct(snapshot.data.rooms);
            } else if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error);
            } else {
              return _buildLoadingWidget();
            }
          },
        ),
      ),
    );
  }

  SliverPersistentHeader makeHeaderSpacer(context) {
    //   final roomModel = Provider.of<Room>(context);

    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverAppBarDelegate(
          minHeight: 10,
          maxHeight: 10,
          child: Row(
            children: [Container()],
          )),
    );
  }

  SliverPersistentHeader makeHeaderDefaultTabs(context) {
    //   final roomModel = Provider.of<Room>(context);

    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverAppBarDelegate(
          minHeight: 70,
          maxHeight: 70,
          child: Row(
            children: [Container()],
          )),
    );
  }

  SliverList makeHeaderInfo(context) {
    final currentTheme = Provider.of<ThemeChanger>(context);

    final thc = (plant.thc.isEmpty) ? '0' : plant.thc;
    final cbd = (plant.cbd.isEmpty) ? '0' : plant.cbd;

    final about = plant.description;
    final size = MediaQuery.of(context).size;

    final germina = plant.germinated;
    final flora = plant.flowering;

    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          color: currentTheme.currentTheme.scaffoldBackgroundColor,
          child: Container(
            margin: EdgeInsets.only(top: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: CbdthcRow(
                    thc: thc,
                    cbd: cbd,
                    fontSize: size.height / 50,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width / 7, vertical: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          alignment: Alignment.center,
                          child: FaIcon(
                            FontAwesomeIcons.seedling,
                            color: (currentTheme.customTheme)
                                ? Colors.white54
                                : Colors.black54,
                          )),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 5.0, vertical: 10.0),
                          child: Container(
                            padding: EdgeInsets.all(3.5),
                            child: Text(
                              "Germinación :",
                              style: TextStyle(
                                  fontSize: size.height / 50,
                                  color: (currentTheme.customTheme)
                                      ? Colors.white54
                                      : Colors.black54),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: size.width / 13),
                        child: Text(
                          "$germina",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size.height / 50,
                            color: (currentTheme.customTheme)
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width / 7, vertical: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          alignment: Alignment.center,
                          child: FaIcon(
                            FontAwesomeIcons.cannabis,
                            color: (currentTheme.customTheme)
                                ? Colors.white54
                                : Colors.black54,
                          )),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 0.0),
                          child: Container(
                            padding: EdgeInsets.all(3.5),
                            child: Text(
                              "Floración :",
                              style: TextStyle(
                                  fontSize: size.height / 50,
                                  color: (currentTheme.customTheme)
                                      ? Colors.white54
                                      : Colors.black54),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: size.width / 8),
                        child: Text(
                          "$flora",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size.height / 50,
                            color: (currentTheme.customTheme)
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          "Semanas",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: size.height / 60,
                            color: (currentTheme.customTheme)
                                ? Colors.white54
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                    width: size.width - 10,
                    padding:
                        EdgeInsets.only(left: size.width / 10.0, right: 30),
                    //margin: EdgeInsets.only(left: size.width / 6, top: 10),

                    child: (about.length > 0)
                        ? convertHashtag(about, context)
                        : Container()),
                SizedBox(
                  height: 40.0,
                ),
                Divider(
                  thickness: 2.0,
                  height: 1.0,
                  color: Colors.grey,
                ),
                SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ),
        )
      ]),
    );
  }

  confirmDelete(BuildContext context, String titulo, String subtitulo,
      String id, Color cardColor) {
    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                backgroundColor: cardColor,
                title: Text(
                  titulo,
                  style: TextStyle(color: Colors.grey),
                ),
                content: Text(
                  subtitulo,
                  style: TextStyle(color: Colors.grey),
                ),
                actions: <Widget>[
                  MaterialButton(
                    child:
                        Text('Eliminar', style: TextStyle(color: Colors.red)),
                    onPressed: () => _deletePlant(id),
                    elevation: 5,
                    textColor: Colors.red,
                  ),
                  MaterialButton(
                    child:
                        Text('Cancelar', style: TextStyle(color: Colors.grey)),
                    onPressed: () => Navigator.pop(context),
                    elevation: 5,
                    textColor: Colors.grey,
                  )
                ],
              ));
    }

    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Text(
                titulo,
              ),
              content: Text(subtitulo),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                  onPressed: () => _deletePlant(id),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child:
                      Text('Cancelar', style: TextStyle(color: Colors.white54)),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ));
  }

  Widget _buildUserWidget(RoomsResponse data) {
    return Container(
      child: Stack(fit: StackFit.expand, children: [
        TabsScrollCustom(
          rooms: data.rooms,
        ),
      ]),
    );
  }

  Widget _buildWidgetProduct(data) {
    return Container(
      child: SizedBox(
        child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return InfoPage(index: index);
            }),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
        height: 400.0, child: Center(child: CircularProgressIndicator()));
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

  Widget itemCake() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 15,
          ),
          Text(
            "Dark Belgium chocolate",
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 15,
                color: Colors.white),
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Cold",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Fresh",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Text(
                    "\$30.25",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.black54),
                  ),
                  Text(
                    "per Quantity",
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 10,
                        color: Colors.black),
                  )
                ],
              )
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 5,
              ),
              Icon(Icons.star, size: 15, color: Colors.orangeAccent),
              Icon(Icons.star, size: 15, color: Colors.orangeAccent),
              Icon(Icons.star, size: 15, color: Colors.orangeAccent),
              Icon(Icons.star, size: 15, color: Colors.orangeAccent),
              Icon(Icons.star, size: 15, color: Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }
}

Route createRoutePrincipalPage() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => PrincipalPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.fastLinearToSlowEaseIn;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: Duration(seconds: 1),
  );
}

Route createRouteChat() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ChatPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
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

Route createRouteRooms() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => RoomsListPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
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

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height / 1.40);

    var firstControlPoint = Offset(size.width / 3, size.height);
    var firstEndPoint = Offset(size.width / 1.30, size.height - 60.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 60);
    var secondEndPoint = Offset(size.width / 1.30, size.height - 60);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 90);
    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

Route createRouteEditPlant(Plant plant) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => AddUpdatePlantPage(
      plant: plant,
      isEdit: true,
    ),
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

Route createRouteNewVisit(Visit visit, String plant, bool isEdit) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => AddUpdateVisitPage(
      visit: visit,
      plant: plant,
      isEdit: isEdit,
    ),
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
          width: size.width / 5,
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
