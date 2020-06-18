import 'package:voiceClient/app/sign_in/developer_menu.dart';
import 'package:voiceClient/app/sign_in/email_link/email_link_sign_in_page.dart';
import 'package:voiceClient/app/sign_in/sign_in_button.dart';
import 'package:voiceClient/constants/strings.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

class SignInPageBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (_) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (_, ValueNotifier<bool> isLoading, __) => SignInPage._(
          isLoading: isLoading.value,
          title: 'My Family Voice',
        ),
      ),
    );
  }
}

class SignInPage extends StatelessWidget {
  const SignInPage._({Key key, this.isLoading, this.title}) : super(key: key);
  final String title;
  final bool isLoading;
  LightSource get lightSource => LightSource.topLeft;
  NeumorphicShape get shape => NeumorphicShape.flat;
  double get depth => 2;
  double get intensity => 0.8;
  double get surfaceIntensity => 0.5;
  double get height => 150.0;
  double get cornerRadius => 20;
  double get width => 150.0;
  double get fontSize => 75;
  int get fontWeight => 500;

  FontWeight _fontWeight() {
    switch (fontWeight ~/ 100) {
      case 1:
        return FontWeight.w100;
      case 2:
        return FontWeight.w200;
      case 3:
        return FontWeight.w300;
      case 4:
        return FontWeight.w400;
      case 5:
        return FontWeight.w500;
      case 6:
        return FontWeight.w600;
      case 7:
        return FontWeight.w700;
      case 8:
        return FontWeight.w800;
      case 9:
        return FontWeight.w900;
    }
    return FontWeight.w500;
  }

  static const Key emailLinkButtonKey = Key('email-link');

  Future<void> _signInWithEmailLink(BuildContext context) async {
    final navigator = Navigator.of(context);
    await EmailLinkSignInPage.show(
      context,
      onSignedIn: navigator.pop,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: Text(title),
      ),
      // Hide developer menu while loading in progress.
      // This is so that it's not possible to switch auth service while a request is in progress
      drawer: isLoading ? null : DeveloperMenu(),
      body: _buildSignIn(context),
    );
  }

  Widget _buildHeader() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return NeumorphicText(
      Strings.signIn,
      textAlign: TextAlign.center,
      textStyle: NeumorphicTextStyle(
        fontSize: fontSize,
        fontWeight: _fontWeight(),
      ),
      style: NeumorphicStyle(
        shape: shape,
        intensity: intensity,
        surfaceIntensity: surfaceIntensity,
        depth: depth,
        lightSource: lightSource,
      ),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    // Make content scrollable so that it fits on small screens
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 12.0),
            SizedBox(
              height: 50.0,
              child: _buildHeader(),
            ),
            SizedBox(height: 52.0),
            SignInButton(
              key: emailLinkButtonKey,
              text: Strings.signInWithEmailLink,
              onPressed: isLoading ? null : () => _signInWithEmailLink(context),
            ),
          ],
        ),
      ),
    );
  }
}
