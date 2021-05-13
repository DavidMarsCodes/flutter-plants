import 'package:chat/models/notification.dart';
import 'package:chat/models/profiles.dart';
import 'package:chat/theme/theme.dart';
import 'package:chat/widgets/avatar_user_chat.dart';
import 'package:chat/widgets/carousel_users.dart';
import 'package:chat/widgets/sliver_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chat/services/auth_service.dart';
import 'package:chat/services/chat_service.dart';
import 'package:chat/services/socket_service.dart';

import 'package:chat/models/mensajes_response.dart';
import 'package:chat/widgets/chat_message.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;

  final String title;
  final Profiles profile;
  final bool isFromMessage;

  CustomAppBar({
    @required this.profile,
    this.title,
    this.isFromMessage,
    Key key,
  })  : preferredSize = Size.fromHeight(60.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeChanger>(context);
    return AppBar(
      backgroundColor: (currentTheme.customTheme) ? Colors.black : Colors.white,
      actions: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Icon(
            Icons.more_vert,
            color: currentTheme.currentTheme.accentColor,
            size: 30,
          ),
        ),
      ],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => (isFromMessage)
                ? Navigator.of(context).push(createRouteProfileSelect(profile))
                : Navigator.of(context).push(createRouteAvatarProfile(profile)),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(100.0)),
              child: Container(
                width: 50,
                height: 50,
                child: Hero(
                    tag: profile.user.uid,
                    child: Material(
                      type: MaterialType.transparency,
                      child: ImageUserChat(
                          width: 100,
                          height: 100,
                          profile: profile,
                          fontsize: 20),
                    )),
              ),
            ),
          ),
          Container(
              margin: EdgeInsets.only(left: 10),
              child: Text(
                (profile.name.length >= 20)
                    ? profile.name.substring(0, 20)
                    : profile.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: (profile.name.length >= 15) ? 15 : 18,
                    color: (currentTheme.customTheme)
                        ? Colors.white
                        : Colors.black),
              ))
        ],
      ),
      leading: IconButton(
        icon: Icon(
          Icons.chevron_left,
          color: currentTheme.currentTheme.accentColor,
        ),
        iconSize: 35,
        onPressed: () {
          final notifiModel =
              Provider.of<NotificationModel>(context, listen: false);

          notifiModel.number = 0;
          //  Navigator.pushReplacement(context, createRouteProfile()),
          Navigator.pop(context);
        },
        color: Colors.white,
      ),
      automaticallyImplyLeading: true,
    );
  }
}

class ChatPage extends StatefulWidget {
  final bool isFromMessage;
  ChatPage({this.isFromMessage = false});
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textController = new TextEditingController();
  final _focusNode = new FocusNode();

  ChatService chatService;
  SocketService socketService;
  AuthService authService;
  NotificationModel notificationModel;

  List<ChatMessage> _messages = [];
  bool _isWriting = false;

  @override
  void initState() {
    super.initState();

    this.chatService = Provider.of<ChatService>(context, listen: false);
    this.socketService = Provider.of<SocketService>(context, listen: false);
    this.authService = Provider.of<AuthService>(context, listen: false);

    this.socketService.socket.on('personal-message', _listenMessage);

    _chargeRecord(this.chatService.userFor.user.uid);
  }

  void _chargeRecord(String userId) async {
    List<Message> chat = await this.chatService.getChat(userId);

    final history = chat.map((m) => new ChatMessage(
          text: m.message,
          uid: m.by,
          animationController: new AnimationController(
              vsync: this, duration: Duration(milliseconds: 0))
            ..forward(),
        ));

    setState(() {
      _messages.insertAll(0, history);
    });
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

  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeChanger>(context);

    final userFor = chatService.userFor;

    final isClub = this.authService.profile.isClub;

    final suscriptionEnabled =
        (isClub) ? true : userFor.subscribeApproved && userFor.subscribeActive;

    return SafeArea(
      child: Scaffold(
        backgroundColor: currentTheme.currentTheme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          profile: userFor,
          isFromMessage: widget.isFromMessage,
        ),
        body: Container(
          padding: EdgeInsets.all(0),
          child: Column(
            children: <Widget>[
              Flexible(
                  child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: _messages.length,
                itemBuilder: (_, i) => (userFor.user.uid == _messages[i].uid)
                    ? _messages[i]
                    : _messages[i],
                reverse: true,
              )),
              Divider(height: 1),
              Container(
                color: (currentTheme.customTheme) ? Colors.black : Colors.white,
                child: (suscriptionEnabled) ? _inputChat() : _inputDisabled(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputChat() {
    final currentTheme = Provider.of<ThemeChanger>(context);

    return SafeArea(
        child: Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
              child: TextField(
            style: TextStyle(
              color: (currentTheme.customTheme) ? Colors.white : Colors.black,
            ),
            controller: _textController,
            onSubmitted: _handleSubmit,
            onChanged: (texto) {
              setState(() {
                if (texto.trim().length > 0) {
                  _isWriting = true;
                } else {
                  _isWriting = false;
                }
              });
            },
            decoration: InputDecoration.collapsed(
              hintText: 'Enviar mensaje',
              hintStyle: TextStyle(
                  color: (currentTheme.customTheme)
                      ? Colors.white54
                      : Colors.black54),
            ),
            focusNode: _focusNode,
          )),

          // Botón de enviar

          (_isWriting)
              ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    child: IconTheme(
                      data: IconThemeData(
                          color: currentTheme.currentTheme.accentColor),
                      child: IconButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        icon: Icon(Icons.send),
                        onPressed: _isWriting
                            ? () => _handleSubmit(_textController.text.trim())
                            : null,
                      ),
                    ),
                  ),
                )
              : Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    child: IconTheme(
                      data: IconThemeData(
                          color: currentTheme.currentTheme.accentColor),
                      child: IconButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        icon: Container(),
                        onPressed: _isWriting
                            ? () => _handleSubmit(_textController.text.trim())
                            : null,
                      ),
                    ),
                  ),
                )
        ],
      ),
    ));
  }

  Widget _inputDisabled() {
    final currentTheme = Provider.of<ThemeChanger>(context);

    return SafeArea(
        child: Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Icon(
              Icons.error_outline,
              color: (currentTheme.customTheme) ? Colors.white54 : Colors.grey,
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Flexible(
              child: Container(
            child: (authService.profile.isClub)
                ? Text(
                    'Suscripción inactiva.',
                    style: TextStyle(
                      color: (currentTheme.customTheme)
                          ? Colors.white54
                          : Colors.black,
                    ),
                  )
                : Text(
                    'Suscribete para enviar mensajes.',
                    style: TextStyle(
                      color: (currentTheme.customTheme)
                          ? Colors.white54
                          : Colors.black,
                    ),
                  ),
          )),

          // Botón de enviar
        ],
      ),
    ));
  }

  _handleSubmit(String text) {
    if (text.length == 0) return;

    _textController.clear();
    _focusNode.requestFocus();

    final newMessage = new ChatMessage(
      uid: authService.profile.user.uid,
      text: text,
      animationController: AnimationController(
          vsync: this, duration: Duration(milliseconds: 200)),
    );
    _messages.insert(0, newMessage);
    newMessage.animationController.forward();

    setState(() {
      _isWriting = false;
    });

    this.socketService.emit('personal-message', {
      'by': this.authService.profile.user.uid,
      'for': this.chatService.userFor.user.uid,
      'message': text
    });

    this.socketService.emit('principal-message', {
      'by': this.authService.profile.user.uid,
      'for': this.chatService.userFor.user.uid,
      'message': text
    });
  }

  @override
  void dispose() {
    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }

    this.socketService.socket.off('personal-message');
    super.dispose();
  }
}
