import 'package:flutter/material.dart';

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:voiceClient/common_widgets/player_widget.dart';

import 'package:voiceClient/constants/transparent_image.dart';

class StoryPlay extends StatelessWidget {
  const StoryPlay(this.id);

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Family Voice',
          style: TextStyle(color: Colors.black.withOpacity(0.6)),
        ),
        backgroundColor: NeumorphicTheme.currentTheme(context).variantColor,
      ),
      //drawer: getDrawer(context),
      body: _buildPage(context),
    );
  }

  Widget _buildPage(BuildContext context) {
    return Neumorphic(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
      ),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          FadeInImage.memoryNetwork(
            height: 300,
            placeholder: kTransparentImage,
            image: 'http://192.168.1.39:4002/storage/$id.jpg',
          ),
          SizedBox(
            height: 8,
          ),
          PlayerWidget(url: 'http://192.168.1.39:4002/storage/$id.mp3'),
        ],
      ),
    );
  }
}
