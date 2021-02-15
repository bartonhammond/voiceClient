import 'package:MyFamilyVoice/app/sign_in/custom_raised_button.dart';
import 'package:MyFamilyVoice/common_widgets/getDialog.dart';
import 'package:MyFamilyVoice/constants/globals.dart';
import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:MyFamilyVoice/services/auth_service_adapter.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:MyFamilyVoice/app_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:MyFamilyVoice/common_widgets/platform_alert_dialog.dart';
import 'package:MyFamilyVoice/common_widgets/platform_exception_alert_dialog.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/services/auth_service.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';
import 'package:flag/flag.dart';
import 'package:MyFamilyVoice/services/locale_secure_store.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({
    this.showLogout = true,
  });
  final bool showLogout;

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final AuthService auth = Provider.of<AuthService>(context, listen: false);
      await auth.signOut();
      final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
      graphQLAuth.clear();
    } on PlatformException catch (e) {
      await PlatformExceptionAlertDialog(
        title: Strings.logoutFailed.i18n,
        exception: e,
      ).show(context);
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final bool didRequestSignOut = await PlatformAlertDialog(
      key: Key('signOutConfirmation'),
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
    if (!kIsWeb) {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String version = packageInfo.version;
      final String buildNumber = packageInfo.buildNumber;
      return '${config.flavorName} $version+$buildNumber';
    }
    return 'Web';
  }

  Widget drawer(
    AppConfig config,
    BuildContext context,
    String versionBuild,
  ) {
    final TextEditingController emailFieldController = TextEditingController();
    final AuthService authService =
        Provider.of<AuthService>(context, listen: false);
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
          config.authServiceType == AuthServiceType.mock
              ? Card(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                key: Key('emailTextField'),
                                controller: emailFieldController,
                              ),
                            ),
                            CustomRaisedButton(
                              key: Key('submitButton'),
                              text: 'Submit',
                              onPressed: () async {
                                //just for testing - get back to a consistent state
                                collapseFriendWidget = false;
                                //During testing, the "Book Name" is created so email is generated
                                final bool emailValid = RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(emailFieldController.text);

                                if (!emailValid) {
                                  //try to get user by name
                                  final GraphQLClient graphQLClient =
                                      GraphQLProvider.of(context).value;
                                  final QueryOptions _queryOptions =
                                      QueryOptions(
                                    documentNode: gql(getUserByNameQL),
                                    variables: <String, dynamic>{
                                      'name': emailFieldController.text,
                                    },
                                  );

                                  final QueryResult queryResult =
                                      await graphQLClient.query(_queryOptions);
                                  if (queryResult.hasException) {
                                    throw queryResult.exception;
                                  }
                                  await authService.signInWithEmailAndLink(
                                      email: queryResult.data['User'][0]
                                          ['email']);
                                } else {
                                  await authService.signInWithEmailAndLink(
                                      email: emailFieldController.text);
                                }
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              : Container(),
          widget.showLogout
              ? Card(
                  child: ListTile(
                    key: Key('signOutTile'),
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
                    await LocaleSecureStore().setLocale('en');
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
                    await LocaleSecureStore().setLocale('es');
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
                  title: Text('Privacy'),
                  onTap: () async {
                    await getDialog(context, 'Privacy', 'policy.html');
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          return drawer(config, context, versionBuild);
        }
      },
    );
  }
}
