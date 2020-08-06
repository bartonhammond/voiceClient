import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:voiceClient/app/sign_in/sign_in_page/sign_in_page.dart';
import 'package:voiceClient/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/service_locator.dart';
import 'package:voiceClient/constants/keys.dart';
import 'home_page.dart';

/// Builds the signed-in or non signed-in UI, depending on the user snapshot.
/// This widget should be below the [MaterialApp].
/// An [AuthWidgetBuilder] ancestor is required for this widget to work.
/// Note: this class used to be called [LandingPage].
class AuthWidget extends StatelessWidget {
  const AuthWidget({
    Key key,
    @required this.userSnapshot,
  }) : super(key: key);
  final AsyncSnapshot<User> userSnapshot;
  @override
  Widget build(BuildContext context) {
    if (userSnapshot.connectionState == ConnectionState.active) {
      if (userSnapshot.hasData) {
        final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
        graphQLAuth.setUser(userSnapshot.data);
        return FutureBuilder(
            future: graphQLAuth.setupEnvironment(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return GraphQLProvider(
                  client: ValueNotifier(snapshot.data),
                  child: HomePage(key: Key(Keys.homePage)),
                );
              } else {
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            });
      }
      return SignInPageBuilder();
    }
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
