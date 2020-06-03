import 'package:voiceClient/app/sign_in/developer_menu.dart';
import 'package:voiceClient/app/sign_in/email_link/email_link_sign_in_page.dart';
import 'package:voiceClient/app/sign_in/sign_in_button.dart';
import 'package:voiceClient/constants/strings.dart';
import 'package:voiceClient/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInPageBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of<AuthService>(context, listen: false);
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (_) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (_, ValueNotifier<bool> isLoading, __) => SignInPage._(
          isLoading: isLoading.value,
          title: 'Firebase Auth Demo',
        ),
      ),
    );
  }
}

class SignInPage extends StatelessWidget {
  const SignInPage._({Key key, this.isLoading, this.title}) : super(key: key);
  final String title;
  final bool isLoading;

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
        elevation: 2.0,
        title: Text(title),
      ),
      // Hide developer menu while loading in progress.
      // This is so that it's not possible to switch auth service while a request is in progress
      drawer: isLoading ? null : DeveloperMenu(),
      backgroundColor: Colors.grey[200],
      body: _buildSignIn(context),
    );
  }

  Widget _buildHeader() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Text(
      Strings.signIn,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w600),
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
            SizedBox(height: 32.0),
            SizedBox(
              height: 50.0,
              child: _buildHeader(),
            ),
            SizedBox(height: 32.0),
            SignInButton(
              key: emailLinkButtonKey,
              text: Strings.signInWithEmailLink,
              onPressed: isLoading ? null : () => _signInWithEmailLink(context),
              textColor: Colors.white,
              color: Colors.blueGrey[700],
            ),
          ],
        ),
      ),
    );
  }
}
