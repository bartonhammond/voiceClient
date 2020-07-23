import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

@immutable
class FriendButton extends StatelessWidget {
  const FriendButton({
    Key key,
    @required this.text,
    @required this.onPressed,
  }) : super(key: key);

  final String text;
  final VoidCallback onPressed;

  Widget buildText(String text, BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: NeumorphicTheme.defaultTextColor(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: NeumorphicButton(
        child: buildText(
          text,
          context,
        ),
        onPressed: onPressed,
        margin: EdgeInsets.all(5),
        style: NeumorphicStyle(
          border: NeumorphicBorder(
            isEnabled: true,
            width: 1,
            color: Color.fromARGB(50, 235, 166, 166),
          ),
        ),
      ),
    );
  }
}
