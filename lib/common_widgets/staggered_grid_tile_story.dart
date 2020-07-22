import 'package:flutter/material.dart';
import 'package:voiceClient/common_widgets/player_widget.dart';
import 'package:voiceClient/constants/transparent_image.dart';

class StaggeredGridTileStory extends StatelessWidget {
  const StaggeredGridTileStory({
    @required this.onPush,
    @required this.activity,
  });
  final ValueChanged<String> onPush;
  final Map activity;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              //new Center(child: new CircularProgressIndicator()),
              Center(
                child: GestureDetector(
                  onTap: () {
                    onPush(activity['id']);
                  },
                  child: FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image: activity['image'],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: <Widget>[
                    PlayerWidget(
                        key: Key("playWidget${activity['id']}"),
                        url: activity['audio']),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
