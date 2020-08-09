import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

import 'package:voiceClient/common_widgets/player_widget.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/constants/keys.dart';
import 'package:voiceClient/constants/transparent_image.dart';

import 'comments.dart';

// ignore: must_be_immutable
class StaggeredGridTileStory extends StatefulWidget {
  StaggeredGridTileStory({
    @required this.onPush,
    @required this.story,
    @required this.showFriend,
  });
  final ValueChanged<Map<String, dynamic>> onPush;
  Map story;
  final bool showFriend;

  @override
  State<StatefulWidget> createState() => _StaggeredGridTileStoryState();
}

class _StaggeredGridTileStoryState extends State<StaggeredGridTileStory> {
  Future<void> callBack() async {
    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(getStoryByIdQL),
      variables: <String, dynamic>{'id': widget.story['id']},
    );

    final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;

    final QueryResult queryResult = await graphQLClient.query(_queryOptions);

    setState(() {
      widget.story = queryResult.data['Story'][0];
    });
  }

  Widget buildFriend() {
    final DateTime dt = DateTime.parse(widget.story['created']['formatted']);
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
                  image: widget.story['user']['image'],
                ),
              ),
            ),
          ),
          Text(
            widget.story['user']['name'],
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
    final DateTime dt = DateTime.parse(widget.story['created']['formatted']);
    final DateFormat df = DateFormat.yMd().add_jm();
    return Card(
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Center(
                child: GestureDetector(
                  onTap: () {
                    widget.onPush(<String, dynamic>{
                      'id': widget.story['id'],
                      'onFinish': callBack
                    });
                  },
                  child: FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image: widget.story['image'],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: <Widget>[
                    PlayerWidget(
                        key: Key("playWidget${widget.story['id']}"),
                        url: widget.story['audio']),
                  ],
                ),
              )
            ],
          ),
          widget.showFriend
              ? buildFriend()
              : Text(
                  df.format(dt),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
          Comments(
            key: Key(Keys.commentsWidgetExpansionTile),
            story: widget.story,
            fontSize: 12,
          ),
        ],
      ),
    );
  }
}
