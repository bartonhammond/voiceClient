import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:voiceClient/app/sign_in/sign_in_page/sign_in_page.dart';
import 'package:voiceClient/constants/keys.dart';
import 'package:voiceClient/services/auth_service.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/logger.dart' as logger;
import 'package:voiceClient/services/service_locator.dart';

import 'package:voiceClient/app/home_page.dart';

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

  FutureBuilder setupHomePage(User user) {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    graphQLAuth.setUser(user);
    return FutureBuilder<dynamic>(
      future: graphQLAuth.setupEnvironment(),
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
          client: ValueNotifier(snapshot.data),
          child: HomePage(key: Key(Keys.homePage)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userSnapshot != null &&
        userSnapshot.connectionState == ConnectionState.active) {
      if (userSnapshot.hasError) {
        final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
        logger.createMessage(
          userEmail: graphQLAuth.getUser().email,
          source: 'auth_widget',
          shortMessage: userSnapshot.error.toString(),
          stackTrace: StackTrace.current.toString(),
        );
        return Text('\nErrors: \n  ' + userSnapshot.error.toString());
      }
      if (userSnapshot.hasData) {
        return setupHomePage(userSnapshot.data);
      }
      return SignInPageBuilder();
    } else {
      if (userEmail != null && userEmail.isNotEmpty) {
        return setupHomePage(User(
          uid: 'does not matter',
          email: userEmail,
          photoUrl: 'does not matter',
          displayName: 'does not matter',
        ));
      }
    }
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
