import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';
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

  Widget getCommentDetail(Map<String, dynamic> comment) {
    final DateTime dt = DateTime.parse(comment['created']['formatted']);
    final DateFormat df = DateFormat.yMd().add_jm();
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            PlayerWidget(
              key: Key("playWidget${comment['id']}"),
              url: comment['audio'],
              showSlider: false,
            ),
          ],
        ),
        Text(
          comment['from']['name'],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
        ),
        Text(
          df.format(dt),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
        ),
        ConfigurableExpansionTile(
          animatedWidgetFollowingHeader: const Icon(
            Icons.expand_more,
            color: Color(0xff00bcd4),
          ),
          header: Container(
              color: Colors.transparent,
              child: Center(
                  child: Text('', style: TextStyle(color: Color(0xff00bcd4))))),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[Text('Delete')],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[Text('Hide')],
            )
          ],
        )
      ],
    );
  }

  Widget getComments() {
    if (activity['comments'].length == 0) {
      return Container();
    }

    final List<Widget> comments = <Widget>[];
    for (var i = 0; i < activity['comments'].length; i++) {
      comments.add(getCommentDetail(activity['comments'][i]));
      if (i < activity['comments'].length - 1) {
        comments.add(Divider(
          thickness: 3.0,
        ));
      }
    }
    return ConfigurableExpansionTile(
      key: Key(activity['id']),
      animatedWidgetFollowingHeader:
          const Icon(Icons.expand_more, color: Color(0xff00bcd4)),
      header: Container(
          color: Colors.transparent,
          child: Center(
            child: Text('Comments', style: TextStyle(color: Color(0xff00bcd4))),
          )),
      children: comments,
    );
  }

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
          getComments(),
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
