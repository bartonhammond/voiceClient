import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:flutter/services.dart' as services;
import 'package:MyFamilyVoice/app/auth_widget.dart';
import 'package:MyFamilyVoice/app/auth_widget_builder.dart';
import 'package:MyFamilyVoice/app/email_link_error_presenter.dart';
import 'package:MyFamilyVoice/services/auth_service.dart';
import 'package:MyFamilyVoice/services/auth_service_adapter.dart';
import 'package:MyFamilyVoice/services/email_secure_store.dart';
import 'package:MyFamilyVoice/services/firebase_email_link_handler.dart';
import 'package:MyFamilyVoice/services/locale_secure_store.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:MyFamilyVoice/services/logger.dart' as logger;

class MyApp extends StatelessWidget {
  // [initialAuthServiceType] is made configurable for testing
  MyApp({
    this.initialAuthServiceType = AuthServiceType.firebase,
    this.isTesting = false,
    this.userEmail = '',
  });
  final AuthServiceType initialAuthServiceType;
  final bool isTesting;
  final String userEmail;

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

  Future<Locale> getDeviceLocal(BuildContext context) async {
    logger.createMessage(
      userEmail: 'initializing',
      source: 'my_app',
      shortMessage: 'getDeviceLocal start',
      stackTrace: StackTrace.current.toString(),
    );
    final LocaleSecureStore localeSecureStore =
        LocaleSecureStore(flutterSecureStorage: FlutterSecureStorage());
    logger.createMessage(
      userEmail: 'initializing',
      source: 'my_app',
      shortMessage: 'getDeviceLocal after',
      stackTrace: StackTrace.current.toString(),
    );
    return localeSecureStore.getLocale();
  }

  MultiProvider getMultiProvider(BuildContext context, Locale locale) {
    logger.createMessage(
      userEmail: 'initializing',
      source: 'my_app',
      shortMessage: 'multiprovider start',
      stackTrace: StackTrace.current.toString(),
    );

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
        Provider<LocaleSecureStore>(
          create: (_) => LocaleSecureStore(
            flutterSecureStorage: FlutterSecureStorage(),
          ),
        ),
        ProxyProvider2<AuthService, EmailSecureStore, FirebaseEmailLinkHandler>(
          update: (_, AuthService authService, EmailSecureStore storage, __) =>
              FirebaseEmailLinkHandler(
            auth: authService,
            emailStore: storage,
            firebaseDynamicLinks: FirebaseDynamicLinks.instance,
          )..init(),
          dispose: (_, linkHandler) => linkHandler.dispose(),
        ),
      ],
      child: AuthWidgetBuilder(builder: (
        BuildContext context,
        AsyncSnapshot<User> userSnapshot,
      ) {
        logger.createMessage(
          userEmail: 'initializing',
          source: 'my_app',
          shortMessage: 'multiprovider finish',
          stackTrace: StackTrace.current.toString(),
        );

        setupServiceLocator(context);
        logger.createMessage(
          userEmail: 'initizing',
          source: 'my_app',
          shortMessage: 'multiprovider finish',
          stackTrace: StackTrace.current.toString(),
        );
        if (isTesting) {
          return testing(context, locale);
        }
        return MaterialApp(
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
              initialLocale: locale,
              child: EmailLinkErrorPresenter.create(
                context,
                child: AuthWidget(
                  userSnapshot: userSnapshot,
                ),
              )),
        );
      }),
    );
  }

  Widget testing(
    BuildContext context,
    Locale locale,
  ) {
    setupServiceLocator(context);
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: myColorSwatch,
        ),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('es', ''),
        ],
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        color: Color(0xFFF9EBE8),
        home: I18n(
          initialLocale: locale?.languageCode == 'es' ? Locale('es') : null,
          child: AuthWidget(
              userSnapshot: null, //userSnapshot,
              userEmail: userEmail),
        ));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      services.DeviceOrientation.portraitDown,
      services.DeviceOrientation.portraitUp,
    ]);
    Locale locale;
    return FutureBuilder(
      future: getDeviceLocal(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          locale = snapshot.data;

          logger.createMessage(
            userEmail: 'initializing',
            source: 'my_app',
            shortMessage: 'build locale: ${locale.toString()}',
            stackTrace: StackTrace.current.toString(),
          );

          return getMultiProvider(context, locale);
        } else if (snapshot.hasError) {
          logger.createMessage(
            userEmail: 'initializing',
            source: 'my_app',
            shortMessage: 'snapshot has error ${snapshot.error}',
            stackTrace: StackTrace.current.toString(),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
