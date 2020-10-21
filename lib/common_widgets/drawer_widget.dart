import 'package:MyFamilyVoice/app/legal/legal_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:i18n_extension/i18n_widget.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:MyFamilyVoice/app_config.dart';

import 'package:MyFamilyVoice/common_widgets/platform_alert_dialog.dart';
import 'package:MyFamilyVoice/common_widgets/platform_exception_alert_dialog.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/services/auth_service.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';
import 'package:flag/flag.dart';
import 'package:MyFamilyVoice/services/locale_secure_store.dart';

Future<void> _signOut(BuildContext context) async {
  try {
    final AuthService auth = Provider.of<AuthService>(context, listen: false);
    await auth.signOut();
  } on PlatformException catch (e) {
    await PlatformExceptionAlertDialog(
      title: Strings.logoutFailed.i18n,
      exception: e,
    ).show(context);
  }
}

Future<void> _confirmSignOut(BuildContext context) async {
  final bool didRequestSignOut = await PlatformAlertDialog(
    title: Strings.logout.i18n,
    content: Strings.logoutAreYouSure.i18n,
    cancelActionText: Strings.cancel.i18n,
    defaultActionText: Strings.yes.i18n,
  ).show(context);
  if (didRequestSignOut == true) {
    _signOut(context);
  }
}

Future<String> getVersionAndBuild(AppConfig config) async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final String version = packageInfo.version;
  final String buildNumber = packageInfo.buildNumber;

  return '${config.flavorName} $version+$buildNumber';
}

Widget drawer(
  BuildContext context,
  String versionBuild,
  bool showLogout,
) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage('assets/mfv.png'),
            ),
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                bottom: 12.0,
                left: 16.0,
                child: Text(
                  Strings.MFV.i18n,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        Card(
          child: ListTile(
            title: Text(versionBuild),
            onTap: () {},
          ),
        ),
        showLogout
            ? Card(
                child: ListTile(
                  title: Text(Strings.logout.i18n),
                  onTap: () {
                    _confirmSignOut(context);
                  },
                ),
              )
            : Container(),
        ExpansionTile(
          title: Text(Strings.languages.i18n),
          children: <Widget>[
            Card(
              child: ListTile(
                trailing: Flag(
                  'US',
                  height: 30,
                  width: 30,
                ),
                title: Text(Strings.usLocale.i18n),
                onTap: () async {
                  I18n.of(context).locale = Locale('en');
                  final LocaleSecureStore localeSecureStore =
                      Provider.of<LocaleSecureStore>(context, listen: false);
                  await localeSecureStore.setLocale('en');
                },
              ),
            ),
            Card(
              child: ListTile(
                trailing: Flag(
                  'ES',
                  height: 30,
                  width: 30,
                ),
                title: Text(Strings.esLocale.i18n),
                onTap: () async {
                  I18n.of(context).locale = Locale('es');
                  final LocaleSecureStore localeSecureStore =
                      Provider.of<LocaleSecureStore>(context, listen: false);
                  await localeSecureStore.setLocale('es');
                },
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('Legal docs'),
          children: <Widget>[
            Card(
              child: ListTile(
                title: Text('Disclaimer'),
                onTap: () async {
                  await getDialog(context, 'Disclaimer', 'disclaimer.html');
                },
              ),
            ),
            Card(
              child: ListTile(
                title: Text('EULA'),
                onTap: () async {
                  await getDialog(context, 'EULA', 'eula.html');
                },
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Policy'),
                onTap: () async {
                  await getDialog(context, 'Policy', 'policy.html');
                },
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Terms'),
                onTap: () async {
                  await getDialog(context, 'Terms', 'terms.html');
                },
              ),
            )
          ],
        ),
      ],
    ),
  );
}

Future<Widget> getDialog(
    BuildContext context, String title, String fileName) async {
  return showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.only(left: 25, right: 25),
        title: Center(child: Text(title)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        content: Container(
          height: 200,
          width: 300,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                LegalPage(fileName),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget getDrawer(BuildContext context, {bool showLogout = true}) {
  final config = AppConfig.of(context);
  return FutureBuilder(
    future: getVersionAndBuild(config),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else {
        final String versionBuild = snapshot.data;
        return drawer(context, versionBuild, showLogout);
      }
    },
  );
}
