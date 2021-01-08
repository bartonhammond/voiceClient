import 'package:MyFamilyVoice/common_widgets/drawer_widget.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/services/eventBus.dart';
import 'package:MyFamilyVoice/web/auth_dialog.dart';
import 'package:MyFamilyVoice/web/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';

class WebHomePage extends StatefulWidget {
  @override
  _WebHomePageState createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> {
  bool _editing = false;
  @override
  void initState() {
    super.initState();
    eventBus.fire(HideProfileBanner());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          stops: const [0.1, 0.5, 0.7, 0.9],
          colors: [
            Colors.red[100],
            Colors.red[500],
            Colors.purple[100],
            Colors.purple[500],
          ],
        ),
      ),
      child: Scaffold(
        drawer: DrawerWidget(showLogout: false),
        key: GlobalKey<ScaffoldState>(),
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          title: Text(
            Strings.MFV.i18n,
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 3),
          ),
          actions: <Widget>[
            Builder(builder: (context) {
              return IconButton(
                icon: Icon(_editing ? Icons.close : Icons.login),
                onPressed: () {
                  if (mounted)
                    setState(() {
                      _editing = !_editing;
                    });
                },
              );
            }),
          ],
        ),
        body: _editing
            ? AuthDialog()
            : Stack(
                children: <Widget>[
                  LandingPage(),
                ],
              ),
      ),
    );
  }
}
