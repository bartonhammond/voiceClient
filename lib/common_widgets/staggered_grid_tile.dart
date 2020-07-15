import 'package:flutter/material.dart';
import 'package:voiceClient/common_widgets/player_widget.dart';
import 'package:voiceClient/constants/transparent_image.dart';

class StaggeredGridTile extends StatelessWidget {
  const StaggeredGridTile({
    @required this.imageUrl,
    @required this.audioUrl,
  });
  final String imageUrl;
  final String audioUrl;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              //new Center(child: new CircularProgressIndicator()),
              Center(
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: imageUrl,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: <Widget>[
                PlayerWidget(url: audioUrl),
              ],
            ),
          )
        ],
      ),
    );
  }
}
