import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:MyFamilyVoice/common_widgets/player_widget.dart';
import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:MyFamilyVoice/constants/keys.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/constants/transparent_image.dart';
import 'package:MyFamilyVoice/services/host.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';

import 'comments.dart';

// ignore: must_be_immutable
class StaggeredGridTileStory extends StatefulWidget {
  StaggeredGridTileStory({
    @required this.onPush,
    @required this.story,
    @required this.showFriend,
    @required this.onDelete,
  });
  final ValueChanged<Map<String, dynamic>> onPush;
  Map story;
  final bool showFriend;
  final VoidCallback onDelete;

  @override
  State<StatefulWidget> createState() => _StaggeredGridTileStoryState();
}

class _StaggeredGridTileStoryState extends State<StaggeredGridTileStory> {
  bool _showComments = false;
  bool _showTags = false;

  Future<void> callBack() async {
    try {
      final QueryOptions _queryOptions = QueryOptions(
        documentNode: gql(getStoryByIdQL),
        variables: <String, dynamic>{'id': widget.story['id']},
      );

      final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;

      final QueryResult queryResult = await graphQLClient.query(_queryOptions);

      setState(() {
        widget.story = queryResult.data['Story'][0];
      });
    } catch (e) {
      //ignore
    }
  }

  Widget buildFriend() {
    final DeviceScreenType deviceType =
        getDeviceType(MediaQuery.of(context).size);
    int _width = 100;
    int _height = 200;
    switch (deviceType) {
      case DeviceScreenType.desktop:
      case DeviceScreenType.tablet:
        _width = _height = 50;
        break;
      case DeviceScreenType.watch:
        _width = _height = 50;
        break;
      case DeviceScreenType.mobile:
        _width = _height = 50;
        break;
      default:
        _width = _height = 100;
    }

    final DateTime dt = DateTime.parse(widget.story['updated']['formatted']);
    final DateFormat df = DateFormat.yMd().add_jm();

    return Card(
      shadowColor: Colors.white,
      child: Column(
        children: <Widget>[
          Center(
            child: GestureDetector(
              onTap: () {
                widget.onPush(
                  <String, dynamic>{
                    'id': widget.story['id'],
                    'onFinish': callBack,
                    'onDelete': widget.onDelete,
                  },
                );
              },
              child: widget.story['user']['image'] == null
                  ? Image(
                      image: AssetImage('assets/placeholder.png'),
                      width: 100,
                      height: 100,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: FadeInImage.memoryNetwork(
                        height: _height.toDouble(),
                        width: _width.toDouble(),
                        placeholder: kTransparentImage,
                        image: host(
                          widget.story['user']['image'],
                          width: _width,
                          height: _height,
                          resizingType: 'fill',
                          enlarge: 1,
                        ),
                      ),
                    ),
            ),
          ),
          Text(
            widget.story['user']['name'] == null
                ? 'Name...'
                : widget.story['user']['name'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
          ),
          Text(
            df.format(dt),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
          ),
          SizedBox(
            height: 7.toDouble(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DeviceScreenType deviceType =
        getDeviceType(MediaQuery.of(context).size);
    int _width = 100;
    int _height = 100;
    switch (deviceType) {
      case DeviceScreenType.desktop:
      case DeviceScreenType.tablet:
        _width = _height = 200;
        break;
      case DeviceScreenType.watch:
        _width = _height = 250;
        break;
      case DeviceScreenType.mobile:
        _width = _height = 250;
        break;
      default:
        _width = _height = 100;
    }

    final DateTime dt = DateTime.parse(widget.story['updated']['formatted']);
    final DateFormat df = DateFormat.yMd().add_jm();

    final List<String> _tags = [];
    if (widget.story != null && widget.story['hashtags'] != null) {
      final List<dynamic> hashtags = widget.story['hashtags'];
      for (var tag in hashtags) {
        _tags.add(tag['tag']);
      }
    }
    final int commentsLength = widget.story['comments']
        .where((dynamic comment) => comment['status'] == 'new')
        .toList()
        .length;
    return Card(
      shadowColor: Colors.black,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          widget.onPush(<String, dynamic>{
            'id': widget.story['id'],
            'onFinish': callBack,
            'onDelete': widget.onDelete,
          });
        },
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                widget.onPush(<String, dynamic>{
                  'id': widget.story['id'],
                  'onFinish': callBack,
                  'onDelete': widget.onDelete,
                });
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: host(
                    widget.story['image'],
                    width: _width,
                    height: _height,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: <Widget>[
                  PlayerWidget(
                    key: Key("playWidget${widget.story['id']}"),
                    url: host(
                      widget.story['audio'],
                    ),
                    width: _width,
                  ),
                ],
              ),
            ),
            widget.showFriend
                ? buildFriend()
                : Text(
                    df.format(dt),
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
            SizedBox(
              height: 7.toDouble(),
            ),
            InkWell(
                child: Text(
                  Strings.gridStoryShowCommentsText.plural(commentsLength),
                  style: TextStyle(
                    color: Color(0xff00bcd4),
                    fontSize: 16.0,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _showComments = !_showComments;
                  });
                }),
            _showComments
                ? Comments(
                    key: Key(
                        '${Keys.commentsWidgetExpansionTile}-${widget.story["id"]}'),
                    story: widget.story,
                    fontSize: 12,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
