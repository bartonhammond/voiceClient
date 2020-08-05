import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_device_locale/flutter_device_locale.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';

import 'package:voiceClient/app/auth_widget.dart';
import 'package:voiceClient/app/auth_widget_builder.dart';
import 'package:voiceClient/app/email_link_error_presenter.dart';
import 'package:voiceClient/services/auth_service.dart';
import 'package:voiceClient/services/auth_service_adapter.dart';
import 'package:voiceClient/services/email_secure_store.dart';
import 'package:voiceClient/services/firebase_email_link_handler.dart';
import 'package:voiceClient/services/service_locator.dart';

Future<void> main() async {
  // Fix for: Unhandled Exception: ServicesBinding.defaultBinaryMessenger was accessed before the binding was initialized.
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(MyApp());
}

String get host => Platform.isAndroid ? '10.0.2.2' : 'localhost';

class MyApp extends StatelessWidget {
  // [initialAuthServiceType] is made configurable for testing
  const MyApp({
    this.initialAuthServiceType = AuthServiceType.firebase,
  });
  final AuthServiceType initialAuthServiceType;

  Future<Locale> getDeviceLocal() async {
    return await DeviceLocale.getCurrentLocale();
  }

  @override
  Widget build(BuildContext context) {
    Locale locale;
    return FutureBuilder(
        future: getDeviceLocal(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            locale = snapshot.data;
            return MultiProvider(
              providers: [
                Provider<AuthService>(
                  create: (_) => AuthServiceAdapter(
                    initialAuthServiceType: initialAuthServiceType,
                  ),
                  dispose: (_, AuthService authService) =>
                      authService.dispose(),
                ),
                Provider<EmailSecureStore>(
                  create: (_) => EmailSecureStore(
                    flutterSecureStorage: FlutterSecureStorage(),
                  ),
                ),
                ProxyProvider2<AuthService, EmailSecureStore,
                    FirebaseEmailLinkHandler>(
                  update: (_, AuthService authService, EmailSecureStore storage,
                          __) =>
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
                setupServiceLocator(context);
                return MaterialApp(
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
                      initialLocale:
                          locale?.languageCode == 'es' ? Locale('es') : null,
                      child: EmailLinkErrorPresenter.create(
                        context,
                        child: AuthWidget(
                          userSnapshot: userSnapshot,
                        ),
                      )),
                );
              }),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
