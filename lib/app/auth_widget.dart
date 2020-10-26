import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:provider/provider.dart';
import 'package:MyFamilyVoice/app/sign_in/email_link/email_link_sign_in_page.dart';
import 'package:MyFamilyVoice/constants/keys.dart';
import 'package:MyFamilyVoice/services/auth_service.dart';
import 'package:MyFamilyVoice/services/firebase_email_link_handler.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/locale_secure_store.dart';
import 'package:MyFamilyVoice/services/logger.dart' as logger;
import 'package:MyFamilyVoice/services/service_locator.dart';

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
    logger.createMessage(
      userEmail: 'init',
      source: 'auth_widget',
      shortMessage: 'getLocaleFromStorage start',
      stackTrace: StackTrace.current.toString(),
    );
    final LocaleSecureStore localeSecureStore =
        Provider.of<LocaleSecureStore>(context, listen: false);
    final Locale locale = await localeSecureStore.getLocale();
    I18n.of(context).locale = locale;
    logger.createMessage(
      userEmail: 'init',
      source: 'auth_widget',
      shortMessage: 'getLocaleFromStorage finish ${locale.toString()}',
      stackTrace: StackTrace.current.toString(),
    );
    return locale;
  }

  FutureBuilder setupHomePage(BuildContext context, User user) {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    graphQLAuth.setUser(user);
    logger.createMessage(
      userEmail: user.email,
      source: 'auth_widget',
      shortMessage: 'setupHomePage start',
      stackTrace: StackTrace.current.toString(),
    );
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
        return GraphQLProvider(
          client: ValueNotifier(snapshot.data[0]),
          child: I18n(
            initialLocale: snapshot.data[1],
            child: HomePage(key: Key(Keys.homePage)),
          ),
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
      logger.createMessage(
        userEmail: 'init',
        source: 'auth_widget',
        shortMessage: 'no userSnapshot',
        stackTrace: StackTrace.current.toString(),
      );
      final AuthService authService =
          Provider.of<AuthService>(context, listen: false);
      final FirebaseEmailLinkHandler linkHandler =
          Provider.of<FirebaseEmailLinkHandler>(context, listen: false);
      logger.createMessage(
        userEmail: 'init',
        source: 'auth_widget',
        shortMessage: 'going to EmailLinkSignInPage',
        stackTrace: StackTrace.current.toString(),
      );
      return EmailLinkSignInPage(
        authService: authService,
        linkHandler: linkHandler,
        onSignedIn: null,
      );
    } else {
      logger.createMessage(
        userEmail: 'init',
        source: 'auth_widget',
        shortMessage: 'no userSnapshot',
        stackTrace: StackTrace.current.toString(),
      );
      if (userEmail != null && userEmail.isNotEmpty) {
        logger.createMessage(
          userEmail: 'init',
          source: 'auth_widget',
          shortMessage: 'userEmail is notEmpty',
          stackTrace: StackTrace.current.toString(),
        );
        return setupHomePage(
            context,
            User(
              uid: 'does not matter',
              email: userEmail,
              photoUrl: 'does not matter',
              displayName: 'does not matter',
            ));
      }
    }
    logger.createMessage(
      userEmail: 'init',
      source: 'auth_widget',
      shortMessage: 'userEmail was empty, now what? was this testing?',
      stackTrace: StackTrace.current.toString(),
    );
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
