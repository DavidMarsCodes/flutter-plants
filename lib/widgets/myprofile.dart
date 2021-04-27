import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:animations/animations.dart';
import 'package:chat/api/pdf_api.dart';
import 'package:chat/api/pdf_invoice.dart';
import 'package:chat/bloc/catalogo_bloc.dart';
import 'package:chat/bloc/plant_bloc.dart';
import 'package:chat/bloc/product_bloc.dart';
import 'package:chat/bloc/room_bloc.dart';
import 'package:chat/bloc/visit_bloc.dart';
import 'package:chat/models/catalogo.dart';
import 'package:chat/models/catalogos_response.dart';
import 'package:chat/models/invoice.dart';
import 'package:chat/models/plant.dart';
import 'package:chat/models/products.dart';
import 'package:chat/models/profiles.dart';
import 'package:chat/models/room.dart';
import 'package:chat/models/rooms_response.dart';
import 'package:chat/models/visit.dart';
import 'package:chat/pages/chat_page.dart';
import 'package:chat/pages/principalCustom_page.dart';
import 'package:chat/pages/principal_page.dart';
import 'package:chat/pages/product_detail.dart';
import 'package:chat/pages/profile_page2.dart';
import 'package:chat/pages/recipe_image_page.dart';
import 'package:chat/pages/room_list_page.dart';
import 'package:chat/providers/catalogos_provider.dart';
import 'package:chat/providers/products_provider.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/plant_services.dart';
import 'package:chat/services/room_services.dart';
import 'package:chat/theme/theme.dart';
import 'package:chat/widgets/card_product.dart';
import 'package:chat/widgets/menu_drawer.dart';
import 'package:chat/widgets/product_card.dart';
import 'package:chat/widgets/sliver_appBar_snap.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import '../utils//extension.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class MyProfile extends StatefulWidget {
  MyProfile({
    Key key,
    this.title,
    this.isUserAuth = false,
    this.isUserEdit = false,
    @required this.profile,
  }) : super(key: key);

  final String title;

  final bool isUserAuth;

  final bool isUserEdit;
  final Profiles profile;

  @override
  _MyProfileState createState() => new _MyProfileState();
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

class _MyProfileState extends State<MyProfile> with TickerProviderStateMixin {
  ScrollController _scrollController;

  String name = '';
  bool fromRooms = false;
  bool activeTabs = false;

  Future<List<Room>> getRoomsFuture;
  AuthService authService;

  final productService = new ProductsApiProvider();

  final catalogoService = new CatalogosApiProvider();

  List<Widget> myTabsContent = [];

  final roomService = new RoomService();
  double get maxHeight => 200 + MediaQuery.of(context).padding.top;
  double get minHeight => MediaQuery.of(context).padding.bottom;

  bool isLike = false;

  Profiles profile;

  bool myProfile = false;

  int currentIndexTab = 0;

  bool loadinReport = false;

  List<Catalogo> catalogos;

  List<Product> products;

  Catalogo catalogo;

  var itemsTabsCatalogos = <String>[];

  List<Tab> categoryTabsTemp = [];
  List<Tab> categoryTabs = [];

  TabController _tabController;

  List<Tab> myTabs = <Tab>[
    Tab(text: 'loading...'),
  ];

  TabController controller;
  int _currentCount;
  int _currentPosition;

  int itemCount;
  IndexedWidgetBuilder tabBuilder;
  IndexedWidgetBuilder pageBuilder;
  Widget stub;
  ValueChanged<int> onPositionChange;
  ValueChanged<double> onScroll;
  int initPosition;

  List<Room> myRooms = [];
  List<Plant> myPlants = [];
  List<Visit> myVisits = [];

  Profiles thisProfile;

  final productUserBloc = ProductBloc();
  final plantService = new PlantService();

  @override
  void initState() {
    _scrollController = ScrollController()..addListener(() => setState(() {}));

    final authService = Provider.of<AuthService>(context, listen: false);

    profile = authService.profile;

    if (widget.isUserAuth) _chargeMyRooms();
    if (widget.isUserAuth) _chargeMyLastPlantsByUser();
    if (widget.isUserAuth) _chargeMyLastVisitByUser();

    (widget.isUserAuth) ? fetchMyCatalogos() : fetchUserCatalogos();

    super.initState();
  }

  _chargeMyRooms() async {
    roomBloc.getMyRooms(profile.user.uid);

    roomBloc.myRooms.listen((rooms) {
      myRooms = rooms.rooms;
      if (mounted) setState(() {});
    });
  }

  _chargeMyLastPlantsByUser() async {
    plantBloc.getPlantsByUser(profile.user.uid);

    plantBloc.plantsUser.listen((plants) {
      myPlants = plants.plants;
      if (mounted) setState(() {});
    });
  }

  _chargeMyLastVisitByUser() async {
    visitBloc.getVisitsByUser(profile.user.uid);

    visitBloc.visitsUser.listen((visits) {
      myVisits = visits.visits;
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(MyProfile oldWidget) {
    if (_currentCount != itemCount) {
      controller.animation.removeListener(onScrollF);
      controller.removeListener(onPositionChangeF);
      controller.dispose();

      if (initPosition != null) {
        _currentPosition = initPosition;
      }

      if (_currentPosition > itemCount - 1) {
        _currentPosition = itemCount - 1;
        _currentPosition = _currentPosition < 0 ? 0 : _currentPosition;
        if (onPositionChange is ValueChanged<int>) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              onPositionChange(_currentPosition);
            }
          });
        }
      }

      _currentCount = itemCount;
      setState(() {
        controller = TabController(
          length: itemCount,
          vsync: this,
          initialIndex: _currentPosition,
        );
        controller.addListener(onPositionChangeF);
        controller.animation.addListener(onScrollF);
      });
    } else if (initPosition != null) {
      controller.animateTo(initPosition);
    }

    super.didUpdateWidget(oldWidget);
  }

  List<Product> productsPageBuilder = [];

  Catalogo currentCatalogo;

  onPositionChangeF() {
    if (!controller.indexIsChanging) {
      _currentPosition = controller.index;

      if (onPositionChange is ValueChanged<int>) {
        onPositionChange(_currentPosition);
      }
    }
  }

  onScrollF() {
    if (onScroll is ValueChanged<double>) {
      onScroll(controller.animation.value);
    }
  }

  void fetchMyCatalogos() async {
    var result;

    productBloc.getCatalogosProducts(profile.user.uid);

    productBloc.catalogosProducts.listen((data) {
      result = data;

      itemCount = result.catalogosProducts.length;

      tabBuilder =
          (context, index) => Tab(text: result.catalogosProducts[index].name);

      pageBuilder = (context, index) => _buildWidgetProducts(
          result.catalogosProducts[index].products, productUserBloc);

      if (mounted) setState(() {});

      _currentPosition = initPosition ?? 0;
      controller = TabController(
        length: itemCount,
        vsync: this,
        initialIndex: _currentPosition,
      );
      controller.addListener(onPositionChangeF);
      controller.animation.addListener(onScrollF);

      _currentCount = itemCount;
    });
  }

  void fetchUserCatalogos() async {
    var result;

    productUserBloc.getCatalogosUserProducts(
        widget.profile.user.uid, profile.user.uid);

    productUserBloc.catalogosProductsUser.listen((data) {
      result = data;

      itemCount = result.catalogosProducts.length;
      tabBuilder =
          (context, index) => Tab(text: result.catalogosProducts[index].name);

      pageBuilder = (context, index) => _buildWidgetProducts(
          result.catalogosProducts[index].products, productUserBloc);

      if (mounted) setState(() {});

      _currentPosition = initPosition ?? 0;
      controller = TabController(
        length: itemCount,
        vsync: this,
        initialIndex: _currentPosition,
      );
      controller.addListener(onPositionChangeF);
      controller.animation.addListener(onScrollF);

      _currentCount = itemCount;
    });
  }

  bool get _showTitle {
    return _scrollController.hasClients && _scrollController.offset >= 130;
  }

  bool get _showName {
    return _scrollController.hasClients && _scrollController.offset >= 200;
  }

  bool isSuscribeApprove = false;

  GlobalKey<ScaffoldState> scaffolKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    controller.animation.removeListener(onScrollF);
    controller.removeListener(onPositionChangeF);
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeChanger>(context);

    final authService = Provider.of<AuthService>(context, listen: false);

    final isUserAuth = authService.profile.user.uid == widget.profile.user.uid;

    final name = (profile.name == "") ? profile.user.username : profile.name;
    setState(() {
      thisProfile = (widget.isUserAuth && isUserAuth)
          ? authService.profile
          : widget.profile;
    });

    //final username = widget.profile.user.username.toLowerCase();

    return SafeArea(
      child: Scaffold(
          backgroundColor: currentTheme.currentTheme.scaffoldBackgroundColor,
          endDrawer: PrincipalMenu(),
          key: scaffolKey,
          // bottomNavigationBar: BottomNavigation(isVisible: _isVisible),
          body: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, value) {
                return [
                  // header

                  SliverAppBar(
                    stretch: true,
                    stretchTriggerOffset: 250.0,

                    backgroundColor: _showTitle
                        ? (currentTheme.customTheme
                            ? Colors.black
                            : Colors.white)
                        : currentTheme.currentTheme.scaffoldBackgroundColor,
                    leading: Container(
                        margin: EdgeInsets.only(left: 15),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          child: CircleAvatar(
                              child: IconButton(
                                  icon: Icon(Icons.arrow_back_ios,
                                      size: 20,
                                      color: (_showTitle)
                                          ? currentTheme
                                              .currentTheme.accentColor
                                          : (currentTheme.customTheme
                                              ? Colors.white
                                              : Colors.black)),
                                  onPressed: () => {
                                        {},
                                        Navigator.pop(context),
                                      }),
                              backgroundColor: (currentTheme.customTheme
                                  ? Colors.black.withOpacity(0.60)
                                  : Colors.white.withOpacity(0.60))),
                        )),

                    actions: [
                      (!widget.isUserAuth)
                          ? Container(
                              width: 40,
                              height: 40,
                              margin: EdgeInsets.only(right: 20),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0)),
                                child: CircleAvatar(
                                    child: Center(
                                      child: IconButton(
                                        icon: FaIcon(
                                            FontAwesomeIcons.commentDots,
                                            size: 25,
                                            color: (_showTitle)
                                                ? currentTheme
                                                    .currentTheme.accentColor
                                                : (currentTheme.customTheme
                                                    ? Colors.white
                                                    : Colors.black)),
                                        onPressed: () => Navigator.push(
                                            context, createRouteChat()),
                                      ),
                                    ),
                                    backgroundColor: (currentTheme.customTheme
                                        ? Colors.black.withOpacity(0.60)
                                        : Colors.white.withOpacity(0.60))),
                              ))
                          : Container(
                              width: 40,
                              height: 40,
                              margin: EdgeInsets.only(right: 20),
                              child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  child: CircleAvatar(
                                      child: Center(
                                        child: IconButton(
                                          icon: FaIcon(
                                              FontAwesomeIcons.ellipsisV,
                                              size: 20,
                                              color: (_showTitle)
                                                  ? currentTheme
                                                      .currentTheme.accentColor
                                                  : (currentTheme.customTheme
                                                      ? Colors.white
                                                      : Colors.black)),
                                          onPressed: () => {
                                            scaffolKey.currentState
                                                .openEndDrawer()
                                          },
                                        ),
                                      ),
                                      backgroundColor: (currentTheme.customTheme
                                          ? Colors.black.withOpacity(0.60)
                                          : Colors.white.withOpacity(0.60))))),
                    ],

                    centerTitle: false,
                    pinned: true,

                    expandedHeight: maxHeight,
                    shadowColor:
                        currentTheme.currentTheme.scaffoldBackgroundColor,

                    // collapsedHeight: 56.0001,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            (_showName)
                                ? FadeIn(
                                    child: Text(name,
                                        style: TextStyle(
                                          color: (currentTheme.customTheme)
                                              ? Colors.white
                                              : Colors.black,
                                        )))
                                : Container(),
                            (_showName && thisProfile.isClub)
                                ? FadeIn(
                                    child: Container(
                                      margin: EdgeInsets.only(left: 10),
                                      child: Stack(children: [
                                        FaIcon(
                                          FontAwesomeIcons.certificate,
                                          color: currentTheme
                                              .currentTheme.accentColor,
                                          size: 20,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 4.5, top: 4.5),
                                          child: FaIcon(
                                            FontAwesomeIcons.check,
                                            color: (currentTheme.customTheme)
                                                ? Colors.black
                                                : Colors.white,
                                            size: 11,
                                          ),
                                        )
                                      ]),
                                    ),
                                  )
                                : Container(),
                          ]),
                      stretchModes: [
                        StretchMode.zoomBackground,
                        StretchMode.fadeTitle,
                        // StretchMode.blurBackground
                      ],
                      background: ProfilePage(
                        isEmpty: false,
                        loading: false,
                        //image: snapshot.data,
                        isUserAuth: widget.isUserAuth,
                        isUserEdit: widget.isUserEdit,
                        profile: thisProfile,
                      ),
                      centerTitle: true,
                    ),
                  ),

                  (!this.widget.isUserEdit)
                      ? makeInfoProfile(context)
                      : makeHeaderSpacer(context),

                  // makeHeaderSpace(context),

                  (profile.isClub)
                      ? makePrivateAccountMessage(context)
                      : makeHeaderSpacer(context),

                  (itemCount != null)
                      ? SliverAppBar(
                          toolbarHeight: 50,
                          pinned: true,
                          backgroundColor:
                              currentTheme.currentTheme.scaffoldBackgroundColor,
                          automaticallyImplyLeading: false,
                          actions: [Container()],
                          title: Container(
                              alignment: Alignment.centerLeft,
                              child: TabBar(
                                  controller: controller,
                                  indicatorWeight: 5,
                                  isScrollable: true,
                                  labelColor:
                                      currentTheme.currentTheme.accentColor,
                                  unselectedLabelColor: (currentTheme
                                          .customTheme)
                                      ? Colors.white54.withOpacity(0.30)
                                      : currentTheme.currentTheme.primaryColor,
                                  indicatorColor:
                                      currentTheme.currentTheme.accentColor,
                                  indicator: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: currentTheme
                                            .currentTheme.accentColor,
                                        width: 4,
                                      ),
                                    ),
                                  ),
                                  tabs: List.generate(
                                    itemCount,
                                    (index) => FadeInLeft(
                                        child: tabBuilder(context, index)),
                                  ))))
                      : makeHeaderSpacerShort(context)
                ];
              },

              // tab bar view
              body: (itemCount != null)
                  ? TabBarView(
                      controller: controller,
                      children: List.generate(
                          itemCount,
                          (index) => Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        height: 30,
                                        padding: EdgeInsets.only(
                                            left: 20, top: 15, bottom: 0),
                                        child: Text(
                                          'Tratamientos',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold),
                                        )),
                                    Expanded(child: pageBuilder(context, index))
                                  ])),
                    )
                  : Container())),
    );

    /*   (itemCount != null)
                ? TabBarView(
                    controller: controller,
                    children: List.generate(
                      itemCount,
                      (index) => pageBuilder(context, index),
                    ),
                  )
                :  
                Container())); */
  }

  SliverList makeListTabs(context) {
    final currentTheme = Provider.of<ThemeChanger>(context);

    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          child: DefaultTabController(
              length: (catalogos != null) ? catalogos.length : 0,
              child: Scaffold(
                appBar: AppBar(
                    backgroundColor:
                        currentTheme.currentTheme.scaffoldBackgroundColor,
                    bottom: TabBar(
                        indicatorWeight: 3,
                        isScrollable: true,
                        labelColor: currentTheme.currentTheme.accentColor,
                        unselectedLabelColor: (currentTheme.customTheme)
                            ? Colors.white54.withOpacity(0.30)
                            : currentTheme.currentTheme.primaryColor,
                        indicatorColor: currentTheme.currentTheme.accentColor,
                        tabs: List<Widget>.generate(catalogos.length,
                            (int index) {
                          final catalogo = catalogos[index];

                          final name = catalogo.name;
                          final nameCapitalized = name.capitalize();
                          return new Tab(
                            child: Text(
                              (nameCapitalized.length >= 15)
                                  ? nameCapitalized.substring(0, 15) + '...'
                                  : nameCapitalized,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                        onTap: (value) => {
                              setState(() {
                                currentIndexTab = value;
                              })
                            })),
              )),
        ),
      ]),
    );
  }

  SliverPersistentHeader makeHeaderTabs(context) {
    final currentTheme = Provider.of<ThemeChanger>(context);

    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverAppBarDelegate(
        minHeight: 50.0,
        maxHeight: 50.0,
        child: DefaultTabController(
            length: catalogos.length,
            child: Scaffold(
              appBar: AppBar(
                  backgroundColor:
                      currentTheme.currentTheme.scaffoldBackgroundColor,
                  bottom: TabBar(
                      indicatorWeight: 3,
                      isScrollable: true,
                      labelColor: currentTheme.currentTheme.accentColor,
                      unselectedLabelColor: (currentTheme.customTheme)
                          ? Colors.white54.withOpacity(0.30)
                          : currentTheme.currentTheme.primaryColor,
                      indicatorColor: currentTheme.currentTheme.accentColor,
                      tabs:
                          List<Widget>.generate(catalogos.length, (int index) {
                        final catalogo = catalogos[index];

                        final name = catalogo.name;
                        final nameCapitalized = name.capitalize();
                        return new Tab(
                          child: Text(
                            (nameCapitalized.length >= 15)
                                ? nameCapitalized.substring(0, 15) + '...'
                                : nameCapitalized,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 5,
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),
                      onTap: (value) => {
                            setState(() {
                              currentIndexTab = value;
                            })
                          })),
            )),
      ),
    );
  }

  SliverList makeSpace(context) {
    return SliverList(delegate: SliverChildListDelegate([Container()]));
  }

  SliverList makeListCatalogos(context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          height: 500,
          child: StreamBuilder<CatalogosResponse>(
            stream: catalogoBloc.myCatalogos.stream,
            builder: (context, AsyncSnapshot<CatalogosResponse> snapshot) {
              if (snapshot.hasData) {
                catalogos = snapshot.data.catalogos;

                return _buildCatalogoWidget();
              } else if (snapshot.hasError) {
                return _buildErrorWidget(snapshot.error);
              } else {
                return _buildLoadingWidget();
              }
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildWidgetProducts(
      List<Product> products, ProductBloc productUserBloc) {
    final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;

    return Container(
      child: SizedBox(
        child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: products.length,
            itemBuilder: (BuildContext ctxt, int index) {
              products.sort((a, b) => a.name.compareTo(b.name));

              final product = products[index];

              return FadeIn(
                delay: Duration(milliseconds: 100 * index),
                child: Container(
                  padding: EdgeInsets.only(
                      top: 20, left: 20, right: 20, bottom: 0.0),
                  child: OpenContainer(
                      closedElevation: 5,
                      openElevation: 5,
                      closedColor: currentTheme.scaffoldBackgroundColor,
                      openColor: currentTheme.scaffoldBackgroundColor,
                      transitionType: ContainerTransitionType.fade,
                      openShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20.0),
                            topLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0),
                            bottomLeft: Radius.circular(10.0)),
                      ),
                      closedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20.0),
                            topLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0),
                            bottomLeft: Radius.circular(10.0)),
                      ),
                      openBuilder: (_, closeContainer) {
                        return ProductDetailPage(
                          product: product,
                          isUserAuth: widget.isUserAuth,
                          productUserBloc: productUserBloc,
                        );
                      },
                      closedBuilder: (_, openContainer) {
                        return Stack(children: [
                          CardProduct(product: product),
                          buildCircleFavoriteProductProfile(
                              context, product.isLike),
                        ]);
                      }),
                ),
              );
            }),
      ),
    );
  }

  SliverPersistentHeader makeHeaderSpacerShort(context) {
    //   final roomModel = Provider.of<Room>(context);

    return SliverPersistentHeader(
      pinned: false,
      delegate: SliverAppBarDelegate(
          minHeight: 50,
          maxHeight: 50,
          child: Container(
              margin: EdgeInsets.only(top: 10), child: _buildLoadingWidget())),
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

  SliverPersistentHeader makeHeaderTabsMyCatalogos(context) {
    //   final roomModel = Provider.of<Room>(context);

    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverAppBarDelegate(
        minHeight: 300.0,
        maxHeight: 70.0,
        child: StreamBuilder<CatalogosResponse>(
          stream: catalogoBloc.myCatalogos.stream,
          builder: (context, AsyncSnapshot<CatalogosResponse> snapshot) {
            if (snapshot.hasData) {
              catalogos = snapshot.data.catalogos;

              return _buildCatalogoWidget();
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

  SliverPersistentHeader makeRoomsCard(context) {
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
          minHeight: 0,
          maxHeight: 0,
          child: Row(
            children: [Container()],
          )),
    );
  }

  SliverPersistentHeader makeHeaderSpace(context) {
    //   final roomModel = Provider.of<Room>(context);

    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverAppBarDelegate(
          minHeight: 20,
          maxHeight: 20,
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

  SliverToBoxAdapter makeInfoProfile(context) {
    final currentTheme = Provider.of<ThemeChanger>(context);

    final username = thisProfile.user.username.toLowerCase();

    final about = (thisProfile.about == null) ? "" : thisProfile.about;
    final size = MediaQuery.of(context).size;
    final isClub = thisProfile.isClub;

    name = thisProfile.name;

    final nameFinal = name.isEmpty ? "" : name.capitalize();

    return SliverToBoxAdapter(
      child: FadeIn(
        child: Container(
          padding: EdgeInsets.only(top: 10.0, bottom: 15),
          color: currentTheme.currentTheme.scaffoldBackgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!this.widget.isUserEdit)
                Container(
                  child: Container(
                      width: size.width - 15.0,
                      padding:
                          EdgeInsets.only(left: size.width / 20.0, top: 5.0),
                      //margin: EdgeInsets.only(left: size.width / 6, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          (nameFinal == "")
                              ? Text(username,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: (name.length >= 15) ? 20 : 22,
                                      color: (currentTheme.customTheme)
                                          ? Colors.white
                                          : Colors.black))
                              : Text(
                                  (nameFinal.length >= 45)
                                      ? nameFinal.substring(0, 45)
                                      : nameFinal,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize:
                                          (nameFinal.length >= 15) ? 20 : 22,
                                      color: (currentTheme.customTheme)
                                          ? Colors.white
                                          : Colors.black)),
                          (isClub)
                              ? Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Stack(children: [
                                    FaIcon(
                                      FontAwesomeIcons.certificate,
                                      color:
                                          currentTheme.currentTheme.accentColor,
                                      size: 20,
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 4.5, top: 4.5),
                                      child: FaIcon(
                                        FontAwesomeIcons.check,
                                        color: (currentTheme.customTheme)
                                            ? Colors.black
                                            : Colors.white,
                                        size: 11,
                                      ),
                                    )
                                  ]),
                                )
                              : Container(),
                        ],
                      )),
                ),
              if (!this.widget.isUserEdit)
                Expanded(
                  flex: -1,
                  child: Container(
                      width: size.width - 1.10,
                      padding: EdgeInsets.only(
                          left: size.width / 20.0, top: 0.0, bottom: 10),
                      //margin: EdgeInsets.only(left: size.width / 6, top: 10),

                      child: Text('@' + username,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: (username.length >= 16) ? 16 : 18,
                              color: (currentTheme.customTheme)
                                  ? Colors.white.withOpacity(0.60)
                                  : Colors.grey))),
                ),
              Expanded(
                flex: -1,
                child: Container(
                    width: size.width - 50,
                    padding: EdgeInsets.only(
                      left: size.width / 20.0,
                      right: 10,
                    ),
                    //margin: EdgeInsets.only(left: size.width / 6, top: 10),

                    child: (about != null)
                        ? (about.length > 0)
                            ? convertHashtag(about, context)
                            : Container()
                        : null),
              ),
              Row(
                children: [
                  if (widget.isUserAuth)
                    Expanded(
                      flex: 0,
                      child: GestureDetector(
                        onTap: () => {
                          Navigator.of(context).push(PageRouteBuilder(
                            transitionDuration: Duration(milliseconds: 200),
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    RecipeImagePage(
                              profile: widget.profile,
                              isUserAuth: widget.isUserAuth,
                            ),
                          ))
                        },
                        child: Container(
                          padding:
                              EdgeInsets.only(left: size.width / 20, top: 10),
                          child: Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.notesMedical,
                                  size: 20,
                                  color: currentTheme.currentTheme.accentColor,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Mi Receta',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (!widget.isUserAuth && profile.isClub && !isClub)
                    Expanded(
                      flex: 0,
                      child: GestureDetector(
                        onTap: () => {
                          Navigator.of(context).push(PageRouteBuilder(
                            transitionDuration: Duration(milliseconds: 200),
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    RecipeImagePage(profile: widget.profile),
                          ))
                        },
                        child: Container(
                          padding:
                              EdgeInsets.only(left: size.width / 20, top: 10),
                          child: Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.notesMedical,
                                  size: 20,
                                  color: currentTheme.currentTheme.accentColor,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Ver Receta',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  (widget.isUserAuth)
                      ? Expanded(
                          flex: 0,
                          child: GestureDetector(
                            onTap: () async {
                              if (!loadinReport) {
                                setState(() {
                                  loadinReport = true;
                                });

                                final date = DateTime.now();
                                final dueDate = date.add(Duration(days: 7));
                                final regex = RegExp(
                                    "(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])");

                                final about =
                                    profile.about.replaceAll(regex, '');

                                final numberId = profile.id.substring(11, 15);

                                final imageAvatarPath = (profile.imageAvatar !=
                                        "")
                                    ? profile.imageAvatar.replaceAll(
                                        'https://leafety-images.s3.us-east-2.amazonaws.com',
                                        '')
                                    : "";

                                final report = Report(
                                    profile: Profile(
                                      isClub: isClub,
                                      rutClub: thisProfile.rutClub,
                                      name: thisProfile.name,
                                      about: about,
                                      username: thisProfile.user.username,
                                      email: thisProfile.user.email,
                                      imageAvatar: imageAvatarPath,
                                      siteInfo: 'https://leafety.com',
                                    ),
                                    customer: Customer(
                                      name: 'Leafety Holding, SPA.',
                                      email: 'leafety@contacto.com',
                                    ),
                                    info: InvoiceInfo(
                                      date: date,
                                      dueDate: dueDate,
                                      description: '$about',
                                      number:
                                          '${DateTime.now().year}-$numberId',
                                    ),
                                    rooms: List<RoomsItem>.generate(
                                        myRooms.length, (int index) {
                                      final room = myRooms[index];

                                      final nameRoom =
                                          room.name.replaceAll(regex, '');

                                      return RoomsItem(
                                        name: nameRoom,
                                        date: room.createdAt,
                                        totalPlants: room.totalPlants,
                                        totalLights: room.totalLights,
                                        totalAirs: room.totalAirs,
                                      );
                                    }),
                                    plants: List<PlantsItem>.generate(
                                        myPlants.length, (int index) {
                                      final plant = myPlants[index];

                                      final namePlant =
                                          plant.name.replaceAll(regex, '');

                                      return PlantsItem(
                                          name: namePlant,
                                          date: plant.createdAt,
                                          quantity: plant.quantity,
                                          cbd: plant.cbd,
                                          thc: plant.thc,
                                          germination: plant.germinated,
                                          floration: plant.flowering);
                                    }),
                                    visits: List<VisitsItem>.generate(
                                        myVisits.length, (int index) {
                                      final visit = myVisits[index];

                                      final description = visit.description
                                          .replaceAll(regex, '');

                                      return VisitsItem(
                                          description: description,
                                          date: visit.createdAt,
                                          degrees: visit.degrees,
                                          ml: visit.ml,
                                          ph: visit.ph,
                                          electro: visit.electro,
                                          nameAbono: visit.nameAbono,
                                          mlAbono: visit.mlAbono,
                                          grams: (visit.grams != null)
                                              ? visit.grams
                                              : '0');
                                    })

                                    /* [
                                    InvoiceItem(
                                      description: 'Coffee',
                                      date: DateTime.now(),
                                      quantity: 3,
                                      vat: 0.19,
                                      unitPrice: 5.99,
                                    ),
                                    InvoiceItem(
                                      description: 'Water',
                                      date: DateTime.now(),
                                      quantity: 8,
                                      vat: 0.19,
                                      unitPrice: 0.99,
                                    ),
                                    InvoiceItem(
                                      description: 'Orange',
                                      date: DateTime.now(),
                                      quantity: 3,
                                      vat: 0.19,
                                      unitPrice: 2.99,
                                    ),
                                    InvoiceItem(
                                      description: 'Apple',
                                      date: DateTime.now(),
                                      quantity: 8,
                                      vat: 0.19,
                                      unitPrice: 3.99,
                                    ),
                                    InvoiceItem(
                                      description: 'Mango',
                                      date: DateTime.now(),
                                      quantity: 1,
                                      vat: 0.19,
                                      unitPrice: 1.59,
                                    ),
                                    InvoiceItem(
                                      description: 'Blue Berries',
                                      date: DateTime.now(),
                                      quantity: 5,
                                      vat: 0.19,
                                      unitPrice: 0.99,
                                    ),
                                    InvoiceItem(
                                      description: 'Lemon',
                                      date: DateTime.now(),
                                      quantity: 4,
                                      vat: 0.19,
                                      unitPrice: 1.29,
                                    ),
                                  ], */
                                    );

                                final pdfFile =
                                    await PdfInvoiceApi.generate(report);

                                print(pdfFile);

                                if (pdfFile.path.length > 0) {
                                  setState(() {
                                    loadinReport = false;
                                  });

                                  PdfApi.openFile(pdfFile);
                                }
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: size.width / 20, top: 10),
                              child: Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.filePdf,
                                      size: 20,
                                      color:
                                          currentTheme.currentTheme.accentColor,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Mi Reporte',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: (loadinReport)
                                              ? currentTheme
                                                  .currentTheme.accentColor
                                              : Colors.grey),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container()
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter makePrivateAccountMessage(context) {
    final currentTheme = Provider.of<ThemeChanger>(context);

    final size = MediaQuery.of(context).size;

    isSuscribeApprove =
        !widget.isUserAuth && (widget.profile.subscribeApproved != null)
            ? !widget.profile.subscribeApproved
            : false;

    return SliverToBoxAdapter(
      child: Stack(
        children: [
          FadeIn(
            child: Container(
                padding: EdgeInsets.only(top: 0.0),
                color: currentTheme.currentTheme.scaffoldBackgroundColor,
                child: (isSuscribeApprove)
                    ? Container(
                        padding: EdgeInsets.only(left: size.width / 20, top: 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                //Navigator.of(context).pop();
                              },
                              child: new Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    margin: EdgeInsets.only(right: 20),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        border: Border.all(
                                            width: 2, color: Colors.grey)),
                                    child: Icon(
                                      Icons.lock,
                                      size: 35,
                                      color: Colors.grey,
                                    ),
                                  )),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(
                                    'Este club es privado',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: (currentTheme.customTheme)
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                                Container(
                                  width: size.width / 1.7,
                                  child: Text(
                                    'Suscríbete a este club para ver todos sus catálogos y tratamientos.',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15,
                                        color: Colors.grey),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    : Container()),
          )
        ],
      ),
    );
  }

  Widget _buildCatalogoWidget() {
    final currentTheme = Provider.of<ThemeChanger>(context);

    return DefaultTabController(
        length: catalogos.length,
        child: Scaffold(
          appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor:
                  currentTheme.currentTheme.scaffoldBackgroundColor,
              bottom: TabBar(
                  indicatorWeight: 3,
                  isScrollable: true,
                  labelColor: currentTheme.currentTheme.accentColor,
                  unselectedLabelColor: (currentTheme.customTheme)
                      ? Colors.white54.withOpacity(0.30)
                      : currentTheme.currentTheme.primaryColor,
                  indicatorColor: currentTheme.currentTheme.accentColor,
                  tabs: List<Widget>.generate(catalogos.length, (int index) {
                    catalogo = catalogos[index];

                    final name = catalogo.name;
                    final nameCapitalized = name.capitalize();
                    return new Tab(
                      child: Text(
                        (nameCapitalized.length >= 15)
                            ? nameCapitalized.substring(0, 15) + '...'
                            : nameCapitalized,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 5,
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                  onTap: (value) => {
                        _tabController
                            .animateTo((_tabController.index + 1) % 2),
                        setState(() {
                          _tabController.index = value;

                          catalogo = catalogo;
                        })
                      })),
        ));
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
}

Route createRouteRecipeViewImage(Profiles item) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        RecipeImagePage(profile: item),
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

RichText convertHashtag(String text, context) {
  final currentTheme = Provider.of<ThemeChanger>(context);

  List<String> split = text.split(RegExp("#"));

  List<String> hashtags = split.getRange(1, split.length).fold([], (t, e) {
    var texts = e.split(" ");

    if (texts.length > 1) {
      return List.from(t)
        ..addAll(["#${texts.first}", "${e.substring(texts.first.length)}"]);
    }
    return List.from(t)..add("#${texts.first}");
  });

  return RichText(
    text: TextSpan(
      children: [
        TextSpan(
            text: split.first,
            style: TextStyle(
                color: (currentTheme.customTheme)
                    ? Colors.white.withOpacity(0.60)
                    : Colors.grey,
                fontSize: 16))
      ]..addAll(hashtags
          .map((text) => text.contains("#")
              ? TextSpan(
                  text: text,
                  style: TextStyle(
                      color: currentTheme.currentTheme.accentColor,
                      fontSize: 16))
              : TextSpan(
                  text: text,
                  style: TextStyle(
                      color: (currentTheme.customTheme)
                          ? Colors.white.withOpacity(0.60)
                          : Colors.grey,
                      fontSize: 16)))
          .toList()),
    ),
  );
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
