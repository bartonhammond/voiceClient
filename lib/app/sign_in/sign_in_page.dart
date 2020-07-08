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
          title: Strings.MFV,
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
      appBar: NeumorphicAppBar(
        title: Text(title),
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
              color: Colors.black,
              padding: EdgeInsets.all(10),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    text: 'My Family Voice ',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    children: <TextSpan>[
                      TextSpan(
                          text: ' was inspired by the way your family shares ',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                        text: 'memories of photos',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline),
                      ),
                      TextSpan(
                          text: ' from their ',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                        text:
                            'youth, high school, adventures, marriage, military, children, etc.',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline),
                      ),
                      TextSpan(
                          text:
                              ' that you can now share with others in your family. ',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
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
              text: Strings.signInWithEmailLink,
              onPressed: isLoading ? null : () => _signInWithEmailLink(context),
            ),
          ],
        ),
      ),
    );
  }
}
