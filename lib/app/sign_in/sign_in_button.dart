import 'package:voiceClient/common_widgets/custom_raised_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class SignInButton extends CustomRaisedButton {
  SignInButton(
      {Key key, @required String text, @required VoidCallback onPressed})
      : super(
          key: key,
          text: text,
          onPressed: onPressed,
        );
}
