import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/services/debouncer.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/mutation_service.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
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
import 'package:MyFamilyVoice/common_widgets/reactions.dart' as react;
import 'package:uuid/uuid.dart';

import 'comments.dart';

// ignore: must_be_immutable
class StaggeredGridTileStory extends StatefulWidget {
  StaggeredGridTileStory({
    @required this.onPush,
    @required this.story,
    @required this.showFriend,
    @required this.onDelete,
    @required this.onReaction,
  });
  final ValueChanged<Map<String, dynamic>> onPush;
  Map story;
  final bool showFriend;
  final VoidCallback onDelete;
  final VoidCallback onReaction;

  @override
  State<StatefulWidget> createState() => _StaggeredGridTileStoryState();
}

class _StaggeredGridTileStoryState extends State<StaggeredGridTileStory> {
  bool _showComments = false;
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void dispose() {
    _debouncer.stop();
    super.dispose();
  }

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
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(
            color: Colors.grey,
            width: 2.0,
          )),
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
            SizedBox(height: 10),
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
            Container(
              margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              height: 1,
              color: Colors.grey[300],
            ),
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            widget.story['totalLikes'] > 0
                                ? Image.asset(
                                    'assets/images/like.png',
                                    height: 20.0,
                                  )
                                : Container(),
                            widget.story['totalHahas'] > 0
                                ? Image.asset(
                                    'assets/images/haha.png',
                                    height: 20.0,
                                  )
                                : Container(),
                            widget.story['totalJoys'] > 0
                                ? Image.asset(
                                    'assets/images/joy.png',
                                    height: 20.0,
                                  )
                                : Container(),
                            widget.story['totalWows'] > 0
                                ? Image.asset(
                                    'assets/images/wow.png',
                                    height: 20.0,
                                  )
                                : Container(),
                            widget.story['totalSads'] > 0
                                ? Image.asset(
                                    'assets/images/sad.png',
                                    height: 20.0,
                                  )
                                : Container(),
                            widget.story['totalLoves'] > 0
                                ? Image.asset(
                                    'assets/images/love.png',
                                    height: 20.0,
                                  )
                                : Container(),
                            widget.story['totalReactions'] > 0
                                ? SizedBox(width: 5.0)
                                : Container(),
                            widget.story['totalReactions'] > 0
                                ? Text(
                                    widget.story['totalReactions'].toString())
                                : Text(''),
                          ]),
                      commentsLength > 0
                          ? InkWell(
                              child: Text(
                                Strings.gridStoryShowCommentsText
                                    .plural(commentsLength),
                                style: TextStyle(
                                  color: Color(0xff00bcd4),
                                  fontSize: 16.0,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _showComments = !_showComments;
                                });
                              })
                          : Container(),
                    ])),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              height: 1,
              color: Colors.grey[300],
            ),
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .2,
                        child: FlutterReactionButtonCheck(
                          onReactionChanged: (reaction, isChecked) {
                            _debouncer.run(() async {
                              final GraphQLClient graphQLClient =
                                  GraphQLProvider.of(context).value;
                              final GraphQLAuth graphQLAuth =
                                  locator<GraphQLAuth>();
                              final uuid = Uuid();

                              final String _reactionId = uuid.v1();

                              //detach delete current story reaction for this user
                              await deleteUserReactionToStory(
                                graphQLClient,
                                graphQLAuth.getUserMap()['email'],
                                widget.story['id'],
                              );

                              //reaction
                              await createReaction(
                                graphQLClient,
                                _reactionId,
                                widget.story['id'],
                                reactionTypes[reaction.id - 1],
                              );

                              //from user
                              await addReactionFrom(
                                graphQLClient,
                                graphQLAuth.getUserMap()['id'],
                                _reactionId,
                              );

                              //from story
                              await addStoryReaction(
                                graphQLClient,
                                widget.story['id'],
                                _reactionId,
                              );
                              widget.onReaction();
                            });
                          },
                          reactions: react.reactions,
                          initialReaction: react.defaultInitialReaction,
                          selectedReaction: react.reactions[0],
                        ),
                      ),
                      Row(children: <Widget>[
                        Icon(
                          Icons.comment_outlined,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        InkWell(
                            child: Text('Comment'),
                            onTap: () {
                              setState(() {
                                _showComments = !_showComments;
                              });
                            })
                      ]),
                    ])),
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
