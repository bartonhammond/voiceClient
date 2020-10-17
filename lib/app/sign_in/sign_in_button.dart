import 'package:MyFamilyVoice/app/sign_in/custom_raised_button.dart';
import 'package:flutter/material.dart';

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
