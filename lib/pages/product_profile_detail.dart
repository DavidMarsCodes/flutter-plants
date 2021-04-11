import 'dart:async';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:animations/animations.dart';
import 'package:chat/bloc/plant_bloc.dart';
import 'package:chat/bloc/product_bloc.dart';
import 'package:chat/bloc/room_bloc.dart';
import 'package:chat/models/product_principal.dart';
import 'package:chat/models/products.dart';
import 'package:chat/models/profiles.dart';
import 'package:chat/models/room.dart';
import 'package:chat/models/rooms_response.dart';
import 'package:chat/models/visit.dart';
import 'package:chat/pages/add_update_product.dart';
import 'package:chat/pages/add_update_visit.dart';
import 'package:chat/pages/chat_page.dart';
import 'package:chat/pages/plant_detail.dart';
import 'package:chat/pages/principal_page.dart';
import 'package:chat/pages/room_detail.dart';
import 'package:chat/pages/room_list_page.dart';
import 'package:chat/providers/products_provider.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/aws_service.dart';
import 'package:chat/services/chat_service.dart';
import 'package:chat/services/product_services.dart';
import 'package:chat/services/room_services.dart';
import 'package:chat/theme/theme.dart';
import 'package:chat/widgets/avatar_user_chat.dart';
import 'package:chat/widgets/card_product.dart';
import 'package:chat/widgets/carousel_tabs.dart';
import 'package:chat/widgets/myprofile.dart';
import 'package:chat/widgets/plant_card_widget.dart';
import 'package:chat/widgets/productProfile_card.dart';
import 'package:chat/widgets/sliver_appBar_snap.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import '../utils//extension.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ProductProfileDetailPage extends StatefulWidget {
  ProductProfileDetailPage({
    Key key,
    this.title,
    this.products,
    @required this.productProfile,
    this.isUserAuth,
  }) : super(key: key);

  final String title;

  final ProductProfile productProfile;
  final List<Product> products;
  final bool isUserAuth;

  @override
  _ProductDetailPageState createState() => new _ProductDetailPageState();
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

class _ProductDetailPageState extends State<ProductProfileDetailPage>
    with TickerProviderStateMixin {
  ScrollController _scrollController;

  TabController _tabController;

  final productApiProvider = new ProductsApiProvider();
  String name = '';

  Future<List<Room>> getRoomsFuture;
  AuthService authService;
  ProductProfile productProfile;

  Profiles profile;

  final roomService = new RoomService();
  double get maxHeight => 250 + MediaQuery.of(context).padding.top;
  double get minHeight => MediaQuery.of(context).padding.bottom;

  bool isLike = false;

  final plantProductBloc = new PlantBloc();

  @override
  void initState() {
    _scrollController = ScrollController()..addListener(() => setState(() {}));
    _tabController = new TabController(vsync: this, length: 1);

    productBloc.imageUpdate.add(true);

    super.initState();

    final authService = Provider.of<AuthService>(context, listen: false);

    final productService = Provider.of<ProductService>(context, listen: false);

    productService.productProfile = null;
    profile = authService.profile;

    plantProductBloc.getPlantsOrigen(widget.productProfile.product.id);
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

  bool isLikedSave = false;
  int countLikes = 0;
  int countLikesInit = 0;
  bool isCountChange = false;

  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeChanger>(context);
    final size = MediaQuery.of(context).size;

    final aws = Provider.of<AwsService>(context, listen: false);

    final productService = Provider.of<ProductService>(context, listen: false);

    final countInit = widget.productProfile.product.countLikes;

    setState(() {
      productProfile = (productService.productProfile != null)
          ? productService.productProfile
          : widget.productProfile;

      isLikedSave =
          (isCountChange) ? isLikedSave : productProfile.product.isLike;
      countLikes = (isCountChange) ? countLikes : countInit;
    });

    return Scaffold(
        backgroundColor: currentTheme.currentTheme.scaffoldBackgroundColor,
        // bottomNavigationBar: BottomNavigation(isVisible: _isVisible),
        body: GestureDetector(
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
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          child: CircleAvatar(
                              child: IconButton(
                                  icon: Icon(Icons.arrow_back_ios,
                                      size: size.width / 20,
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
                              margin: EdgeInsets.only(left: 0, right: 10),
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
                                            break;

                                          case '2':
                                            aws.isUploadImagePlant = false;
                                            productService.productProfile =
                                                productProfile;

                                            Navigator.of(context).push(
                                                createRouteEditProduct(
                                                    widget
                                                        .productProfile.product,
                                                    plantProductBloc));
                                            break;
                                          case '3':
                                            confirmDelete(
                                                context,
                                                'Confirmar',
                                                'Desea eliminar el tratamiento?',
                                                widget
                                                    .productProfile.product.id,
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  child: LikeButton(
                                                    isLiked: isLikedSave,
                                                    onTap: onLikeButtonTapped,
                                                    bubblesColor: BubblesColor(
                                                      dotPrimaryColor:
                                                          currentTheme
                                                              .currentTheme
                                                              .accentColor,
                                                      dotSecondaryColor:
                                                          currentTheme
                                                              .currentTheme
                                                              .accentColor,
                                                    ),
                                                    likeBuilder: (
                                                      bool isLiked,
                                                    ) {
                                                      return Icon(
                                                        (!isLikedSave)
                                                            ? Icons
                                                                .favorite_border
                                                            : Icons.favorite,
                                                        color: isLikedSave
                                                            ? currentTheme
                                                                .currentTheme
                                                                .accentColor
                                                            : Colors.white54,
                                                        size: isLikedSave
                                                            ? 28
                                                            : 28,
                                                      );
                                                    },
                                                    likeCount: countLikes,
                                                    countBuilder: (int count,
                                                        bool isLiked,
                                                        String text) {
                                                      return Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10),
                                                          child: Text(
                                                              '$countLikes'));
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5.0,
                                                ),
                                                /* Text('$countLikes',
                                                    style: TextStyle(
                                                        color: currentTheme
                                                            .currentTheme
                                                            .accentColor)), */
                                              ],
                                            )),
                                        PopupMenuItem<String>(
                                            value: '2',
                                            child: Container(
                                              padding:
                                                  EdgeInsets.only(left: 10),
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
                                              ),
                                            )),
                                        PopupMenuItem<String>(
                                          value: '3',
                                          child: Container(
                                            padding: EdgeInsets.only(left: 10),
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
                                        ),
                                      ],
                                    ),
                                    backgroundColor: _showTitle
                                        ? (currentTheme.customTheme)
                                            ? Colors.black54
                                            : Colors.white54
                                        : Colors.black54),
                              ))
                          : Container(
                              margin: EdgeInsets.only(right: 10),
                              child: CircleAvatar(
                                  child: LikeButton(
                                    isLiked: isLikedSave,
                                    onTap: onLikeButtonTapped,
                                    circleColor: CircleColor(
                                        start: Colors.white,
                                        end: currentTheme
                                            .currentTheme.accentColor),
                                    bubblesColor: BubblesColor(
                                      dotPrimaryColor:
                                          currentTheme.currentTheme.accentColor,
                                      dotSecondaryColor:
                                          currentTheme.currentTheme.accentColor,
                                    ),
                                    likeBuilder: (bool isLiked) {
                                      return Icon(
                                        (!isLikedSave)
                                            ? Icons.favorite_border
                                            : Icons.favorite,
                                        color: isLikedSave
                                            ? currentTheme
                                                .currentTheme.accentColor
                                            : Colors.white54,
                                        size: isLikedSave ? 28 : 28,
                                      );
                                    },
                                  ),
                                  backgroundColor: _showTitle
                                      ? (currentTheme.customTheme)
                                          ? Colors.black54
                                          : Colors.white54
                                      : Colors.black54))
                      //  _buildCircleQuantityPlant(),
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
                                    child: cachedNetworkImage(
                                        productProfile.product.getCoverImg())),
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
                            )),
                        centerTitle: true,
                        title: Container(
                            //  margin: EdgeInsets.only(left: 0),
                            width: size.height / 2,
                            height: 25,
                            child: Container(
                              child: Center(
                                child: Text(
                                  (productProfile.product.name.isNotEmpty)
                                      ? productProfile.product.name.capitalize()
                                      : '',
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
                  makeHeaderInfo(context),
                  makeListPlants(context)
                ])));
  }

  Future<bool> onLikeButtonTapped(bool isLiked) async {
    /// send your request here
    // final bool success= await sendRequest();

    final success = await productApiProvider.addUpdateFavorite(
        productProfile.product.id, profile.user.uid);

    /// if failed, you can do nothing

    isLikedSave = success.favorite.isLike;

    isCountChange = true;

    (isLikedSave) ? countLikes++ : countLikes--;
    productBloc.getProductsPrincipal(profile.user.uid);

    return isLikedSave;
  }

  SliverPersistentHeader makeHeaderTabs(context) {
    final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;
    final size = MediaQuery.of(context).size;

    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverAppBarDelegate(
        minHeight: size.height / 7,
        maxHeight: size.height / 7,
        child: DefaultTabController(
          length: 1,
          child: Scaffold(
            appBar: AppBar(
              leading: null,
              backgroundColor: currentTheme.scaffoldBackgroundColor,
              bottom: TabBar(
                  labelColor: currentTheme.accentColor,
                  indicatorWeight: 3.0,
                  indicatorColor: currentTheme.accentColor,
                  tabs: [
                    Tab(
                        text: 'Vistas',
                        icon: FaIcon(FontAwesomeIcons.eye,
                            color: (_tabController.index == 0)
                                ? currentTheme.accentColor
                                : Colors.grey)),
                  ],
                  onTap: (value) => {}),
            ),
          ),
        ),
      ),
    );
  }

  _deleteProduct(
    String id,
  ) async {
    final res = await this.productApiProvider.deleteProduct(id);
    if (res) {
      setState(() {
        //    widget.plants.removeAt(index);

        productBloc.getProductsPrincipal(profile.user.uid);

        Navigator.pop(context);
        Navigator.pop(context);
      });
    }
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

  SliverList makeListPlants(context) {
    final currentTheme = Provider.of<ThemeChanger>(context);
    final size = MediaQuery.of(context).size;

    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          child: StreamBuilder(
            stream: plantProductBloc.plantsSelected.stream,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                final plants = snapshot.data;
                if (plants.length > 0) {
                  return Stack(
                    children: [
                      Container(
                          margin: EdgeInsets.only(bottom: 0),
                          alignment: Alignment.center,
                          child: Text(
                              (plants.length == 1)
                                  ? 'Planta de origen'
                                  : 'Plantas de origen',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: (currentTheme.customTheme)
                                    ? Colors.white54
                                    : Colors.black54,
                              ))),
                      Container(child: _buildWidgetPlant(plants))
                    ],
                  );
                } else {
                  return Center(
                    child: Container(
                        padding: EdgeInsets.all(50),
                        child: Text(
                          'Sin Plantas de origen',
                          style: TextStyle(
                            fontSize: size.width / 30,
                            color: (currentTheme.customTheme)
                                ? Colors.white54
                                : Colors.black54,
                          ),
                        )),
                  );
                }
              } else {
                return _buildLoadingWidget();
              }
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildWidgetPlant(plants) {
    final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;

    return Container(
      child: SizedBox(
        child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: plants.length,
            itemBuilder: (BuildContext ctxt, int index) {
              final plant = plants[index];

              return Stack(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        top: 10, left: 20, right: 20, bottom: 20.0),
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
                          return PlantDetailPage(
                            plant: plant,
                            isUserAuth: widget.isUserAuth,
                          );
                        },
                        closedBuilder: (_, openContainer) {
                          return FadeIn(
                            child: Stack(children: [
                              CardPlant(plant: plant),
                              (widget.isUserAuth)
                                  ? Container(
                                      child: buildCircleQuantityPlantDash(
                                          plant.quantity, context),
                                    )
                                  : Container(),
                            ]),
                          );
                        }),
                  ),
                ],
              );
            }),
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

    final authService = Provider.of<AuthService>(context);

    final profile = authService.profile;

    final thc =
        (productProfile.product.thc.isEmpty) ? '0' : productProfile.product.thc;
    final cbd =
        (productProfile.product.cbd.isEmpty) ? '0' : productProfile.product.cbd;

    final about = productProfile.product.description;
    final size = MediaQuery.of(context).size;
    final rating = widget.productProfile.product.ratingInit;

    var ratingDouble = double.parse('$rating');

    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          color: currentTheme.currentTheme.scaffoldBackgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    EdgeInsets.only(top: 10, left: size.width / 5, bottom: 5.0),
                child: CbdthcRow(
                  thc: thc,
                  cbd: cbd,
                  fontSize: 15,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                  width: size.width - 5,
                  padding: EdgeInsets.only(left: size.width / 10.0, right: 30),
                  //margin: EdgeInsets.only(left: size.width / 6, top: 10),

                  child: (about.length > 0)
                      ? convertHashtag(about, context)
                      : Container()),
              SizedBox(
                height: 10.0,
              ),
              Container(
                padding:
                    EdgeInsets.only(top: 10, left: size.width / 5, bottom: 5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    (ratingDouble >= 1)
                        ? Icon(
                            Icons.star,
                            size: 30,
                            color: Colors.orangeAccent,
                          )
                        : Icon(
                            Icons.star,
                            size: 30,
                            color: Colors.grey,
                          ),
                    (ratingDouble >= 2)
                        ? Icon(
                            Icons.star,
                            size: 30,
                            color: Colors.orangeAccent,
                          )
                        : Icon(
                            Icons.star,
                            size: 30,
                            color: Colors.grey,
                          ),
                    (ratingDouble >= 3)
                        ? Icon(
                            Icons.star,
                            size: 30,
                            color: Colors.orangeAccent,
                          )
                        : Icon(
                            Icons.star,
                            size: 30,
                            color: Colors.grey,
                          ),
                    (ratingDouble >= 4)
                        ? Icon(
                            Icons.star,
                            size: 30,
                            color: Colors.orangeAccent,
                          )
                        : Icon(
                            Icons.star,
                            size: 30,
                            color: Colors.grey,
                          ),
                    (ratingDouble == 5)
                        ? Icon(
                            Icons.star,
                            size: 30,
                            color: Colors.orangeAccent,
                          )
                        : Icon(
                            Icons.star,
                            size: 30,
                            color: Colors.grey,
                          ),
                    SizedBox(
                      width: 20,
                    ),
                    Container(
                      child: Text(
                        '$ratingDouble',
                        style: TextStyle(
                            color: (currentTheme.customTheme)
                                ? Colors.white
                                : Colors.black,
                            fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              GestureDetector(
                onTap: () {
                  //profile.user.uid = '';
                  //Navigator.pushNamed(context, 'detail', arguments: profile);

                  if (productProfile.profile.user.uid != profile.user.uid) {
                    final chatService =
                        Provider.of<ChatService>(context, listen: false);
                    chatService.userFor = productProfile.profile;
                    Navigator.push(context,
                        createRouteProfileSelect(productProfile.profile));
                  } else {
                    Navigator.push(context, createRouteProfile());
                  }
                },
                child: Container(
                  padding: EdgeInsets.only(
                      top: 10, left: size.width / 5, bottom: 5.0),
                  child: Row(
                    children: [
                      Container(
                        child: ImageUserChat(
                            width: 100,
                            height: 100,
                            profile: productProfile.profile,
                            fontsize: 20),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Text(
                                productProfile.profile.name,
                                style: TextStyle(
                                    fontSize: 15,
                                    color: (currentTheme.customTheme)
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold),
                              )),
                          Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Text(
                                '@' + productProfile.profile.user.username,
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
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
                    onPressed: () => _deleteProduct(id),
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
                  onPressed: () => _deleteProduct(id),
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
      child: TabsScrollCustom(
        rooms: data.rooms,
      ),
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
    final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;

    return Container(
        padding: EdgeInsets.only(right: 10),
        height: 200.0,
        child: Center(
            child: CircularProgressIndicator(
                backgroundColor: currentTheme.accentColor)));
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

Route createRouteEditProduct(Product product, PlantBloc plantProductBloc) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        AddUpdateProductPage(
            product: product, isEdit: true, plantProductBloc: plantProductBloc),
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

Route createRouteProfileSelect(Profiles profile) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        MyProfile(profile: profile),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5.0),
      child: Row(
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
            width: 40,
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
      ),
    );
  }
}
