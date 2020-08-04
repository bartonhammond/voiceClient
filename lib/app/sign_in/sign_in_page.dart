import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'package:voiceClient/app/sign_in/email_link/email_link_sign_in_page.dart';
import 'package:voiceClient/app/sign_in/sign_in_button.dart';
import 'package:voiceClient/constants/strings.dart';
import 'package:voiceClient/constants/mfv.i18n.dart';

class SignInPageBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (_) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (_, ValueNotifier<bool> isLoading, __) => SignInPage._(
          isLoading: isLoading.value,
          title: Strings.MFV.i18n,
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
      appBar: AppBar(
        title: Text(title),
        backgroundColor: NeumorphicTheme.currentTheme(context).variantColor,
      ),
      body: _buildSignIn(context),
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
            Container(
              //color: NeumorphicTheme.currentTheme(context).variantColor,
              padding: EdgeInsets.all(10),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    text: Strings.MFV.i18n,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    children: <TextSpan>[
                      TextSpan(
                          text: Strings.inspiredText.i18n,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                        text: Strings.memoriesText.i18n,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline),
                      ),
                      TextSpan(
                        text: Strings.firebase.i18n,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(
                          text: Strings.youCanShare.i18n,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            SignInButton(
                key: emailLinkButtonKey,
                text: Strings.signInWithEmailLink.i18n,
                onPressed:
                    isLoading ? null : () => _signInWithEmailLink(context),
                icon: Icon(
                  MdiIcons.login,
                  color: Colors.white,
                )),
          ],
        ),
      ),
    );
  }
}
