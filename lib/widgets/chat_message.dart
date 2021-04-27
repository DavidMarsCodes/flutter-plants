import 'package:chat/theme/theme.dart';
import 'package:chat/widgets/text_emoji.dart';
import 'package:flutter/material.dart';
import 'package:chat/services/auth_service.dart';
import 'package:provider/provider.dart';

class ChatMessage extends StatelessWidget {
  final String text;
  final String uid;
  final AnimationController animationController;

  const ChatMessage(
      {Key key,
      @required this.text,
      @required this.uid,
      @required this.animationController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return FadeTransition(
      opacity: animationController,
      child: SizeTransition(
        sizeFactor:
            CurvedAnimation(parent: animationController, curve: Curves.easeOut),
        child: Container(
          child: this.uid == authService.profile.user.uid
              ? _myMessage(context)
              : _notMyMessage(),
        ),
      ),
    );
  }

  Widget _myMessage(context) {
    final currentTheme = Provider.of<ThemeChanger>(context);

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.only(right: 5, bottom: 5, left: 50),
        child: EmojiText(
            text: this.text,
            style: TextStyle(color: Colors.black, fontSize: 15),
            emojiFontMultiplier: 2),
        decoration: BoxDecoration(
            color: currentTheme.currentTheme.accentColor,
            borderRadius: BorderRadius.circular(50)),
      ),
    );
  }

  Widget _notMyMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.only(left: 5, bottom: 5, right: 50),
        child: EmojiText(
            text: this.text,
            style: TextStyle(color: Colors.black, fontSize: 15),
            emojiFontMultiplier: 2),
        decoration: BoxDecoration(
            color: Color(0xff969B9B), borderRadius: BorderRadius.circular(50)),
      ),
    );
  }
}
