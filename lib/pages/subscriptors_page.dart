import 'package:animate_do/animate_do.dart';
import 'package:chat/bloc/subscribe_bloc.dart';
import 'package:chat/models/profiles.dart';
import 'package:chat/models/profiles_response.dart';
import 'package:chat/pages/principalCustom_page.dart';
import 'package:chat/pages/recipe_image_page.dart';
import 'package:chat/providers/notifications_provider.dart';
import 'package:chat/providers/subscription_provider.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/chat_service.dart';
import 'package:chat/services/socket_service.dart';
import 'package:chat/theme/theme.dart';
import 'package:chat/widgets/avatar_user_chat.dart';
import 'package:chat/widgets/chat_message.dart';
import 'package:chat/widgets/header_appbar_pages.dart';
import 'package:chat/widgets/myprofile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

class SubscriptorsPage extends StatefulWidget {
  SubscriptorsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SubscriptorsPageState createState() => _SubscriptorsPageState();
}

class _SubscriptorsPageState extends State<SubscriptorsPage>
    with TickerProviderStateMixin {
  final notificationsProvider = new NotificationsProvider();

  final subscriptionApiProvider = new SubscriptionApiProvider();

  ChatService chatService;
  SocketService socketService;
  AuthService authService;
  Profiles profile;
  List<ChatMessage> _messages = [];
  List<Profiles> profiles = [];
  SlidableController slidableController;

  final List<_HomeItem> items = List.generate(
    20,
    (i) => _HomeItem(
      i,
      'Tile n°$i',
      _getSubtitle(i),
      _getAvatarColor(i),
    ),
  );

  @protected
  void initState() {
    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
    this.chatService = Provider.of<ChatService>(context, listen: false);
    this.socketService = Provider.of<SocketService>(context, listen: false);
    this.authService = Provider.of<AuthService>(context, listen: false);
    profile = authService.profile;
    this.socketService.socket.on('personal-message', _listenMessage);

    subscriptionBloc.getSubscriptionsApprove(profile.user.uid);

    super.initState();
  }

  @override
  void dispose() {
    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }

    super.dispose();
  }

  void _listenMessage(dynamic payload) {
    ChatMessage message = new ChatMessage(
      text: payload['message'],
      uid: payload['by'],
      animationController: AnimationController(
          vsync: this, duration: Duration(milliseconds: 300)),
    );

    setState(() {
      _messages.insert(0, message);
    });

    message.animationController.forward();
  }

  Animation<double> rotationAnimation;
  Color fabColor = Colors.blue;

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {
    setState(() {
      rotationAnimation = slideAnimation;
    });
  }

  void handleSlideIsOpenChanged(bool isOpen) {
    setState(() {
      fabColor = isOpen ? Colors.green : Colors.blue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        body: CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: <Widget>[
              makeHeaderCustom(
                  (profile.isClub) ? 'Mis Pacientes' : 'Mis clubes'),
              makeListNotifications(context)
            ]),
        // bottomNavigationBar: BottomNavigation(isVisible: _isVisible),
      ),
    );
  }

  SliverList makeListNotifications(
    context,
  ) {
    return SliverList(
        delegate: SliverChildListDelegate([
      Container(
        padding: EdgeInsets.only(top: 20),
        child: _buildList(
          context,
          Axis.vertical,
        ),
      ),
    ]));
  }

  SliverPersistentHeader makeHeaderCustom(String title) {
    return SliverPersistentHeader(
        floating: true,
        delegate: SliverCustomHeaderDelegate(
            minHeight: 60,
            maxHeight: 60,
            child: Container(
                color: Colors.black,
                child: Container(
                    color: Colors.black,
                    child: CustomAppBarHeaderPages(
                        title: title, action: Container())))));
  }

  Widget _buildList(BuildContext context, Axis direction) {
    final currentTheme = Provider.of<ThemeChanger>(context);

    return StreamBuilder<ProfilesResponse>(
      stream: subscriptionBloc.subscriptionsApprove.stream,
      builder: (context, AsyncSnapshot<ProfilesResponse> snapshot) {
        if (snapshot.hasData) {
          profiles = snapshot.data.profiles;

          if (profiles.length > 0) {
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: profiles.length,
              itemBuilder: (BuildContext ctxt, int index) {
                var item = profiles[index];

                final DateTime dateMessage = item.messageDate;

                final DateFormat formatter = DateFormat('dd MMM - kk:mm a');
                final String formatted = formatter.format(dateMessage);
                final nameSub =
                    (item.name == "") ? item.user.username : item.name;
                return Column(
                  children: [
                    //final int t = index;
                    FadeInLeft(
                      delay: Duration(milliseconds: 300 * index),
                      child: Slidable.builder(
                        key: Key(item.id),
                        controller: slidableController,
                        direction: Axis.horizontal,
                        actionPane: _getActionPane(index),
                        actionExtentRatio: 0.25,
                        child: InkWell(
                          onTap: () {},
                          child: Material(
                            child: ListTile(
                              tileColor: (currentTheme.customTheme)
                                  ? currentTheme.currentTheme.cardColor
                                  : Colors.white,
                              leading: ImageUserChat(
                                  width: 100,
                                  height: 100,
                                  profile: item,
                                  fontsize: 20),
                              title: Text(nameSub,
                                  style: TextStyle(
                                      color: (currentTheme.customTheme)
                                          ? Colors.white54
                                          : Colors.black54,
                                      fontSize: 18)),
                              subtitle: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Text(
                                      'Aprobado: $formatted',
                                      style: TextStyle(
                                          color: (currentTheme.customTheme)
                                              ? Colors.white54
                                              : Colors.black54,
                                          fontSize: 15),
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      'SUSCRITO',
                                      style: TextStyle(
                                          color: currentTheme
                                              .currentTheme.accentColor,
                                          fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Container(
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  Icons.chevron_right,
                                  color: currentTheme.currentTheme.accentColor,
                                  size: 30,
                                ),
                              ),
                              onTap: () {
                                final chatService = Provider.of<ChatService>(
                                    context,
                                    listen: false);
                                chatService.userFor = item;

                                Navigator.of(context)
                                    .push(createRouteProfileSelect(item));
                              },
                            ),
                          ),
                        ),
                        secondaryActionDelegate: SlideActionBuilderDelegate(
                            actionCount: 1,
                            builder:
                                (context, index, animation, renderingMode) {
                              return IconSlideAction(
                                caption: 'Eliminar',
                                color: renderingMode ==
                                        SlidableRenderingMode.slide
                                    ? Colors.red.withOpacity(animation.value)
                                    : Colors.red,
                                icon: Icons.delete,
                                onTap: () async {
                                  var state = Slidable.of(context);
                                  var dismiss = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.black,
                                        title: Text(
                                          'Eliminar Solicitud',
                                          style:
                                              TextStyle(color: Colors.white54),
                                        ),
                                        content: Text(
                                          'Se desaprobara la solicitud',
                                          style:
                                              TextStyle(color: Colors.white54),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text(
                                              'Cancelar',
                                              style: TextStyle(
                                                  color: Colors.white54),
                                            ),
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                          ),
                                          TextButton(
                                            child: Text(
                                              'Ok',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (dismiss) {
                                    state.dismiss();
                                  }
                                },
                              );
                            }),
                      ),
                    ),
                    Divider(height: 1),
                  ],
                );
              },
            );
          } else {
            return _buildEmptyWidget();
          }
        } else if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error);
        } else {
          return _buildLoadingWidget();
        }
      },
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
        height: 400.0,
        child: Center(
            child: Text(
          'Vacio',
          style: TextStyle(color: Colors.grey),
        )));
  }

  _deleteSubscription(String id, int index) async {
    final res = await this.subscriptionApiProvider.disapproveSubscription(id);
    if (res) {
      setState(() {
        subscriptionBloc.getSubscriptionsApprove(profile.user.uid);
      });
    }
  }

  _approveSubscription(String id, int index) async {
    final res = await this.subscriptionApiProvider.approveSubscription(id);
    if (res) {
      setState(() {
        subscriptionBloc.getSubscriptionsApprove(profile.user.uid);
      });
    }
  }

  Route createRouteProfileSelect(Profiles profile) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => MyProfile(
        title: '',
        profile: profile,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 400),
    );
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

  Widget _buildLoadingWidget() {
    final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;

    return Container(
        height: 400.0,
        child: Center(
            child: CircularProgressIndicator(
          color: currentTheme.accentColor,
        )));
  }

  Route createRouteRecipeViewImage(Profiles item) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          RecipeImagePage(profile: item),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 400),
    );
  }

  static Widget _getActionPane(int index) {
    switch (index % 4) {
      case 0:
        return SlidableBehindActionPane();
      case 1:
        return SlidableStrechActionPane();
      case 2:
        return SlidableScrollActionPane();
      case 3:
        return SlidableDrawerActionPane();
      default:
        return null;
    }
  }

  static Color _getAvatarColor(int index) {
    switch (index % 4) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.indigoAccent;
      default:
        return null;
    }
  }

  static String _getSubtitle(int index) {
    switch (index % 4) {
      case 0:
        return 'SlidableBehindActionPane';
      case 1:
        return 'SlidableStrechActionPane';
      case 2:
        return 'SlidableScrollActionPane';
      case 3:
        return 'SlidableDrawerActionPane';
      default:
        return null;
    }
  }

  void _showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.black,
        content: Text(text,
            style: TextStyle(
              color: Colors.white54,
            ))));
  }
}

class _HomeItem {
  const _HomeItem(
    this.index,
    this.title,
    this.subtitle,
    this.color,
  );

  final int index;
  final String title;
  final String subtitle;
  final Color color;
}
