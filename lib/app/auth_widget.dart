import 'package:MyFamilyVoice/services/locale_secure_store.dart';
import 'package:MyFamilyVoice/web/web_home_page.dart';
import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:provider/provider.dart';
import 'package:MyFamilyVoice/app/sign_in/email_link/email_link_sign_in_page.dart';
import 'package:MyFamilyVoice/constants/keys.dart';
import 'package:MyFamilyVoice/services/auth_service.dart';
import 'package:MyFamilyVoice/services/firebase_email_link_handler.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/logger.dart' as logger;
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:MyFamilyVoice/app/home_page.dart';

/// Builds the signed-in or non signed-in UI, depending on the user snapshot.
/// This widget should be below the [MaterialApp].
/// An [AuthWidgetBuilder] ancestor is required for this widget to work.
/// Note: this class used to be called [LandingPage].
class AuthWidget extends StatelessWidget {
  const AuthWidget({
    Key key,
    @required this.userSnapshot,
    this.userEmail,
  }) : super(key: key);

  final AsyncSnapshot<User> userSnapshot;
  final String userEmail;

  Future<Locale> getLocaleFromStorage(BuildContext context) async {
    Locale locale = await LocaleSecureStore().getLocale();
    locale ??= Locale('en');

    I18n.of(context).locale = locale;

    return locale;
  }

  FutureBuilder setupHomePage(BuildContext context, User user) {
    print('authWidget.setupHomePage user: ${user.email}');
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    graphQLAuth.setUser(user);

    return FutureBuilder<dynamic>(
      future: Future.wait([
        graphQLAuth.setupEnvironment(),
        getLocaleFromStorage(context),
      ]),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          logger.createMessage(
            userEmail: graphQLAuth.getUser().email,
            source: 'auth_widget',
            shortMessage: snapshot.error.toString(),
            stackTrace: StackTrace.current.toString(),
          );
          return Text('\nErrors: \n  ' + snapshot.error.toString());
        } else if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return I18n(
          initialLocale: snapshot.data[1],
          child: HomePage(key: Key(Keys.homePage)),
        );
      },
    );
  }

  FutureBuilder setupWebHomePage(BuildContext context) {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

    return FutureBuilder<dynamic>(
      future: Future.wait([
        graphQLAuth.setupEnvironment(), //note User was set in AuthDialog
        getLocaleFromStorage(context),
      ]),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          logger.createMessage(
            userEmail: graphQLAuth.getUser().email,
            source: 'auth_widget',
            shortMessage: snapshot.error.toString(),
            stackTrace: StackTrace.current.toString(),
          );
          return Text('\nErrors: \n  ' + snapshot.error.toString());
        } else if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return I18n(
          initialLocale: snapshot.data[1],
          child: WebHomePage(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userSnapshot != null &&
        userSnapshot.connectionState == ConnectionState.active) {
      if (userSnapshot.hasError) {
        logger.createMessage(
          userEmail: 'init',
          source: 'auth_widget userSnapshot has error',
          shortMessage: userSnapshot.error.toString(),
          stackTrace: StackTrace.current.toString(),
        );
        return Text('\nErrors: \n  ' + userSnapshot.error.toString());
      }
      if (userSnapshot.hasData) {
        return setupHomePage(context, userSnapshot.data);
      }
      if (kIsWeb) {
        return setupWebHomePage(context);
      } else {
        final AuthService authService =
            Provider.of<AuthService>(context, listen: false);
        final FirebaseEmailLinkHandler linkHandler =
            Provider.of<FirebaseEmailLinkHandler>(context, listen: false);

        return EmailLinkSignInPage(
          authService: authService,
          linkHandler: linkHandler,
          onSignedIn: null,
        );
      }
    }
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
