import 'package:voiceClient/app/sign_in/custom_raised_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class SignInButton extends CustomRaisedButton {
  const SignInButton(
      {Key key,
      @required String text,
      @required VoidCallback onPressed,
      Icon icon})
      : super(
          key: key,
          text: text,
          onPressed: onPressed,
          icon: icon,
        );
}
