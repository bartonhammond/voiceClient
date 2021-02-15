import 'package:flutter/material.dart';
import 'package:MyFamilyVoice/app/sign_in/custom_raised_button.dart';

@immutable
class MessageButton extends StatelessWidget {
  const MessageButton({
    Key key,
    @required this.text,
    @required this.fontSize,
    @required this.icon,
    @required this.onPressed,
  }) : super(key: key);

  final String text;
  final double fontSize;
  final Icon icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CustomRaisedButton(
      text: text,
      fontSize: fontSize,
      onPressed: onPressed,
      icon: icon,
    );
  }
}
