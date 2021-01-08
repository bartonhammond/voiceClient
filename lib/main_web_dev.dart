import 'package:MyFamilyVoice/app/auth_widget.dart';
import 'package:MyFamilyVoice/app/auth_widget_builder.dart';
import 'package:MyFamilyVoice/app_config.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/services/auth_service.dart';
import 'package:MyFamilyVoice/services/auth_service_adapter.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:MyFamilyVoice/web/webauthentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:provider/provider.dart';

void main(List<String> args) {
  HttpLink getHttpLink(String uri) {
    return HttpLink(uri: uri);
  }

  final configuredApp = AppConfig(
    flavorName: 'Web',
    websocket: 'ws://192.168.1.14:3000',
    apiBaseUrl: 'http://192.168.1.13',
    getHttpLink: getHttpLink,
    isSecured: false,
    isWeb: true,
    child: MyApp(),
  );

  runApp(configuredApp);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MaterialColor myColorSwatch = MaterialColor(0xff00bcd4, const {
    50: Color.fromRGBO(4, 131, 184, .1),
    100: Color.fromRGBO(4, 131, 184, .2),
    200: Color.fromRGBO(4, 131, 184, .3),
    300: Color.fromRGBO(4, 131, 184, .4),
    400: Color.fromRGBO(4, 131, 184, .5),
    500: Color.fromRGBO(4, 131, 184, .6),
    600: Color.fromRGBO(4, 131, 184, .7),
    700: Color.fromRGBO(4, 131, 184, .8),
    800: Color.fromRGBO(4, 131, 184, .9),
    900: Color.fromRGBO(4, 131, 184, 1),
  });
  Future getUserInfo() async {
    await getUser();
    setState(() {});
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthServiceAdapter(
            initialAuthServiceType: AuthServiceType.firebase,
          ),
          dispose: (_, AuthService authService) => authService.dispose(),
        ),
      ],
      child: AuthWidgetBuilder(
        builder: (
          BuildContext context,
          AsyncSnapshot<User> userSnapshot,
        ) {
          setupServiceLocator(context);
          return GraphQLProvider(
            client: ValueNotifier(
              GraphQLAuth(context)
                  .getGraphQLClient(GraphQLClientType.ApolloServer),
            ),
            child: MaterialApp(
              theme: ThemeData(
                primarySwatch: myColorSwatch,
              ),
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('es'),
              ],
              debugShowCheckedModeBanner: false,
              themeMode: ThemeMode.light,
              color: Color(0xFFF9EBE8),
              home: I18n(
                initialLocale: Locale('en'),
                child: AuthWidget(
                  userSnapshot: userSnapshot,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
