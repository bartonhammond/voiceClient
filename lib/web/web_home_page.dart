import 'package:MyFamilyVoice/constants/constants.dart';
import 'package:MyFamilyVoice/web/auth_dialog.dart';
import 'package:flutter/material.dart';

class WebHomePage extends StatefulWidget {
  static const String route = '/';

  @override
  _WebHomePageState createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> {
  ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size(screenSize.width, 1000),
        child: Container(),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Stack(
              children: [
                AuthDialog(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
