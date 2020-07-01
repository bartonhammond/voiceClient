import 'dart:io';
import 'package:voiceClient/app/auth_widget_builder.dart';
import 'package:voiceClient/app/email_link_error_presenter.dart';
import 'package:voiceClient/app/auth_widget.dart';
import 'package:voiceClient/services/auth_service.dart';
import 'package:voiceClient/services/auth_service_adapter.dart';
import 'package:voiceClient/services/firebase_email_link_handler.dart';
import 'package:voiceClient/services/email_secure_store.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

import 'package:graphql_flutter/graphql_flutter.dart';

Future<void> main() async {
  // Fix for: Unhandled Exception: ServicesBinding.defaultBinaryMessenger was accessed before the binding was initialized.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

String get host => Platform.isAndroid ? '10.0.2.2' : 'localhost';

class MyApp extends StatelessWidget {
  // [initialAuthServiceType] is made configurable for testing
  const MyApp({
    this.initialAuthServiceType = AuthServiceType.firebase,
  });
  final AuthServiceType initialAuthServiceType;

  @override
  Widget build(BuildContext context) {
    final httpLink = HttpLink(
      //uri: 'http://$host:4001/graphql',
      uri: 'http://192.168.1.39:4001/query',
    );

    final client = ValueNotifier(
      GraphQLClient(
        cache: InMemoryCache(),
        link: httpLink,
      ),
    );

    // MultiProvider for top-level services that can be created right away
    return MultiProvider(
        providers: [
          Provider<AuthService>(
            create: (_) => AuthServiceAdapter(
              initialAuthServiceType: initialAuthServiceType,
            ),
            dispose: (_, AuthService authService) => authService.dispose(),
          ),
          Provider<EmailSecureStore>(
            create: (_) => EmailSecureStore(
              flutterSecureStorage: FlutterSecureStorage(),
            ),
          ),
          ProxyProvider2<AuthService, EmailSecureStore,
              FirebaseEmailLinkHandler>(
            update:
                (_, AuthService authService, EmailSecureStore storage, __) =>
                    FirebaseEmailLinkHandler(
              auth: authService,
              emailStore: storage,
              firebaseDynamicLinks: FirebaseDynamicLinks.instance,
            )..init(),
            dispose: (_, linkHandler) => linkHandler.dispose(),
          ),
        ],
        child: GraphQLProvider(
          client: client,
          child: AuthWidgetBuilder(builder: (
            BuildContext context,
            AsyncSnapshot<User> userSnapshot,
          ) {
            return NeumorphicApp(
              debugShowCheckedModeBanner: false,
              title: 'Flutter Demo',
              themeMode: ThemeMode.light,
              theme: NeumorphicThemeData(
                baseColor: Color(0xFFFFFFFF),
                lightSource: LightSource.topRight,
                depth: 50,
              ),
              darkTheme: NeumorphicThemeData(
                baseColor: Color(0xFF3E3E3E),
                lightSource: LightSource.topRight,
                depth: 50,
              ),
              home: EmailLinkErrorPresenter.create(
                context,
                child: AuthWidget(userSnapshot: userSnapshot),
              ),
            );
          }),
        ));
  }
}
