import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:voiceClient/app/sign_in/sign_in_page/sign_in_widget.dart';

class SignInPageTablet extends StatelessWidget {
  const SignInPageTablet({Key key, this.isLoading, this.title})
      : super(key: key);
  final String title;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Color(0xff00bcd4),
      ),
      body: SignInWidget().buildSignIn(context, isLoading),
    );
  }
}
