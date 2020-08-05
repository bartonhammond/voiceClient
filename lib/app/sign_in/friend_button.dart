import 'package:flutter/material.dart';

import 'package:voiceClient/app/sign_in/sign_in_button.dart';

@immutable
class FriendButton extends StatelessWidget {
  const FriendButton({
    Key key,
    @required this.text,
    @required this.onPressed,
  }) : super(key: key);

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SignInButton(
      text: text,
      onPressed: onPressed,
    );
  }
}
