import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:voiceClient/common_widgets/player_widget.dart';
import 'package:voiceClient/constants/transparent_image.dart';

class StaggeredGridTileStory extends StatelessWidget {
  const StaggeredGridTileStory({
    @required this.onPush,
    @required this.activity,
    @required this.showFriend,
  });
  final ValueChanged<String> onPush;
  final Map activity;
  final bool showFriend;

  Widget buildFriend() {
    final DateTime dt = DateTime.parse(activity['created']['formatted']);
    final DateFormat df = DateFormat.yMd().add_jm();

    return Card(
      child: Column(
        children: <Widget>[
          Center(
            child: GestureDetector(
              onTap: () {},
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35.0),
                child: FadeInImage.memoryNetwork(
                  height: 35,
                  width: 35,
                  placeholder: kTransparentImage,
                  image: activity['user']['image'],
                ),
              ),
            ),
          ),
          Text(
            activity['user']['name'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
          ),
          Text(
            df.format(dt),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime dt = DateTime.parse(activity['created']['formatted']);
    final DateFormat df = DateFormat.yMd().add_jm();
    return Card(
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
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
          showFriend
              ? buildFriend()
              : Text(
                  df.format(dt),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                )
        ],
      ),
    );
  }
}
