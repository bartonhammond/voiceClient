import 'dart:io' as io;
import 'dart:typed_data';
import 'package:MyFamilyVoice/app_config.dart';
import 'package:MyFamilyVoice/common_widgets/friend_widget.dart';
import 'package:MyFamilyVoice/common_widgets/image_editor/image_zoom.dart';
import 'package:MyFamilyVoice/common_widgets/platform_alert_dialog.dart';
import 'package:MyFamilyVoice/common_widgets/reaction_table.dart';
import 'package:MyFamilyVoice/common_widgets/recorder_widget.dart';
import 'package:MyFamilyVoice/common_widgets/recorder_widget_web.dart';
import 'package:MyFamilyVoice/common_widgets/tagged_friends.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/ql/story/story_comments.dart';
import 'package:MyFamilyVoice/ql/story/story_original_user.dart';
import 'package:MyFamilyVoice/ql/story/story_reactions.dart';
import 'package:MyFamilyVoice/ql/story/story_search.dart';
import 'package:MyFamilyVoice/ql/story/story_tags.dart';
import 'package:MyFamilyVoice/ql/story/story_user.dart';
import 'package:MyFamilyVoice/ql/story_ql.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/mutation_service.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:MyFamilyVoice/services/utilities.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:MyFamilyVoice/common_widgets/player_widget.dart';
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
    @required this.onBanned,
    this.index,
    this.crossAxisCount,
    this.showCollapsed = false,
  });
  final ValueChanged<Map<String, dynamic>> onPush;
  Map story;
  final bool showFriend;
  final bool showCollapsed;
  final VoidCallback onDelete;
  final VoidCallback onBanned;
  final int index;
  final int crossAxisCount;

  @override
  State<StatefulWidget> createState() => _StaggeredGridTileStoryState();
}

class _StaggeredGridTileStoryState extends State<StaggeredGridTileStory> {
  bool _showComments = false;
  bool _showMakeComments = false;
  bool _showReactionTotals = false;
  bool _uploadInProgress = false;
  bool _showAttentions = false;
  final GlobalKey _key = GlobalKey();
  final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
  io.File _commentAudio;
  Uint8List _commentAudioWeb;
  bool _isWeb = false;
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> callBack() async {
    try {
      //any changes here need to be coordinated w/ stories_page
      final StoryUser storyUser = StoryUser();
      final StoryOriginalUser storyOriginalUser = StoryOriginalUser();
      final StoryComments storyComments = StoryComments();
      final StoryReactions storyReactions = StoryReactions();
      final StoryTags storyTags = StoryTags();

      final StoryQl storyQl = StoryQl(
        storyUser: storyUser,
        storyOriginalUser: storyOriginalUser,
        storyComments: storyComments,
        storyReactions: storyReactions,
        storyTags: storyTags,
      );
      final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;

      final StorySearch storySearch = StorySearch.init(
        graphQLClient,
        storyQl,
        graphQLAuth.getUserMap()['email'],
      );
      storySearch.setQueryName('getStoryById');
      storySearch.setVariables(
        <String, dynamic>{
          'id': 'String!',
          'currentUserEmail': 'String!',
        },
      );

      final Map story = await storySearch.getItem(<String, dynamic>{
        'id': widget.story['id'],
        'currentUserEmail': graphQLAuth.getUserMap()['email'],
      });
      setState(() {
        widget.story = story;
      });
    } catch (e) {
      print('sgts.callback failed $e');
    }
  }

  Future<void> setCommentAudioFile(io.File audio) async {
    if (audio == null) {
      return;
    }
    setState(() {
      _commentAudio = audio;
      _uploadInProgress = true;
    });

    final GraphQLClient graphQLClientFileServer =
        graphQLAuth.getGraphQLClient(GraphQLClientType.FileServer);

    final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;

    await doCommentUploads(
      graphQLAuth,
      graphQLClientFileServer,
      graphQLClient,
      widget.story,
      commentAudio: _commentAudio,
    );
    setState(() {
      _commentAudio = null;
      _uploadInProgress = false;
      _showMakeComments = false;
    });
    callBack();
    return;
  }

  Future<void> setCommentAudioWeb(Uint8List bytes) async {
    if (bytes == null) {
      return;
    }
    setState(() {
      _commentAudioWeb = bytes;
      _uploadInProgress = true;
    });

    final GraphQLClient graphQLClientFileServer =
        graphQLAuth.getGraphQLClient(GraphQLClientType.FileServer);

    final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;

    await doCommentUploads(
      graphQLAuth,
      graphQLClientFileServer,
      graphQLClient,
      widget.story,
      commentAudioWeb: _commentAudioWeb,
    );
    setState(() {
      _commentAudioWeb = null;
      _uploadInProgress = false;
      _showMakeComments = false;
    });
    callBack();
    return;
  }

  Alignment getAlignment() {
    if (widget.crossAxisCount == 3) {
      switch (widget.index % 3) {
        case 0:
          return Alignment.centerLeft;
        case 1:
          return Alignment.center;
        case 2:
          return Alignment.centerRight;
      }
    }
    return Alignment.center;
  }

  @override
  Widget build(BuildContext context) {
    _isWeb = AppConfig.of(context).isWeb;
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

    final int commentsLength = widget.story['comments']
        .where((dynamic comment) => comment['status'] == 'new')
        .toList()
        .length;

    final config = AppConfig.of(context);
    final String apiBaseUrl = config.apiBaseUrl;
    Reaction _initialReaction = react.defaultInitialReaction;
    String _initialReactionId;
    printJson('sgts.build', widget.story);
    if (widget.story['reactions'] != null &&
        widget.story['reactions'].length > 0) {
      for (var reaction in widget.story['reactions']) {
        if (reaction['from']['email'] == graphQLAuth.getUserMap()['email']) {
          _initialReaction =
              react.reactions[reactionTypes.indexOf(reaction['type'])];
          _initialReactionId = reaction['id'];
          break;
        }
      }
    }

    return Card(
        key: _key,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: BorderSide(
              color: Colors.grey,
              width: 2.0,
            )),
        shadowColor: Colors.black,
        child: InkWell(
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
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Strings.storyPlayAudience.i18n,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      widget.story['type'],
                      key: Key('storyPlayAudience'),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (context) => ImageZoom(
                        imageUrl: '$apiBaseUrl/jpg${widget.story["image"]}',
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: host(
                        widget.story['image'],
                        width: _width,
                        height: _height,
                      )),
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
                      showSlider: _isWeb ? false : true,
                      width: _width,
                    ),
                  ],
                ),
              ),
              widget.showFriend
                  ? FriendWidget(
                      user: widget.story['user'],
                      onPush: widget.onPush,
                      story: widget.story,
                      onDelete: widget.onDelete,
                      callBack: callBack,
                      onBanned: widget.onBanned,
                      showBorder: false,
                      showMessage: false,
                      showFamilyCheckbox: false,
                    )
                  : Text(
                      df.format(dt),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
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
                    InkWell(
                      key: Key('reactionTotals-${widget.index}'),
                      onTap: () {
                        setState(() {
                          _showReactionTotals = !_showReactionTotals;
                          _showComments = false;
                          _showMakeComments = false;
                          _showAttentions = false;
                        });
                      },
                      child: Row(
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
                              ? Text(widget.story['totalReactions'].toString())
                              : Text(''),
                        ],
                      ),
                    ),
                    commentsLength > 0
                        ? InkWell(
                            child: AutoSizeText(
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
                                _showMakeComments = false;
                                _showReactionTotals = false;
                                _showAttentions = false;
                              });
                            })
                        : Text(''),
                  ],
                ),
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
                      Builder(
                        builder: (BuildContext c) {
                          return FlutterReactionButtonCheck(
                            isChecked: false,
                            key: Key('reaction-${widget.index}'),
                            boxAlignment: getAlignment(),
                            onReactionChanged: (reaction, isChecked) async {
                              final GraphQLClient graphQLClient =
                                  GraphQLProvider.of(context).value;

                              final uuid = Uuid();

                              final String _reactionId = uuid.v1();

                              if (isChecked && reaction.id != 0) {
                                if (_initialReactionId != null) {
                                  await changeReaction(
                                    graphQLClient,
                                    originalReactionId: _initialReactionId,
                                    reactionId: uuid.v1(),
                                    type: reactionTypes[reaction.id - 1],
                                    storyId: widget.story['id'],
                                    userId: graphQLAuth.getUserMap()['id'],
                                  );
                                } else {
                                  await createReaction(
                                    graphQLClient,
                                    reactionId: uuid.v1(),
                                    type: reactionTypes[reaction.id - 1],
                                    storyId: widget.story['id'],
                                    userId: graphQLAuth.getUserMap()['id'],
                                  );
                                }
                              } else {
                                //detach delete current story reaction for this user
                                await deleteUserReactionToStory(
                                  graphQLClient,
                                  graphQLAuth.getUserMap()['email'],
                                  widget.story['id'],
                                );
                              }
                              //get the updated story
                              callBack();
                            },
                            reactions: react.reactions,
                            initialReaction: _initialReaction,
                            //selectedReaction: react.defaultInitialReaction,
                          );
                        },
                      ),
                      widget.story['tags'].length > 0
                          ? Row(
                              children: [
                                Icon(
                                  Icons.group_add,
                                  size: 20,
                                ),
                                const SizedBox(width: 5),
                                InkWell(
                                  child: Text(Strings.storyPlayAttention.i18n,
                                      key: Key(
                                          'attentionButton-${widget.story["user"]["name"]}')),
                                  onTap: () async {
                                    setState(() {
                                      _showMakeComments = false;
                                      _showComments = false;
                                      _showReactionTotals = false;
                                      _showAttentions = !_showAttentions;
                                    });
                                  },
                                ),
                              ],
                            )
                          : Container(),
                      Row(children: [
                        Icon(
                          Icons.comment,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        InkWell(
                            child: Text(Strings.commentRequest.i18n,
                                key: Key('commentButton-${widget.index}')),
                            onTap: () {
                              setState(() {
                                _showMakeComments = !_showMakeComments;
                                _showComments = false;
                                _showReactionTotals = false;
                                _showAttentions = false;
                              });
                            }),
                      ]),
                    ]),
              ),
              _showComments || _showAttentions
                  ? Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      height: 1,
                      color: Colors.grey[300],
                    )
                  : Container(),
              _showAttentions
                  ? TaggedFriends(
                      key: Key('tagFriendsTileStory'),
                      items: widget.story['tags'],
                    )
                  : Container(),
              _showComments
                  ? Comments(
                      showExpand: true,
                      key: Key(
                          '${Keys.commentsWidgetExpansionTile}-${widget.story["user"]["name"]}'),
                      story: widget.story,
                      fontSize: 12,
                      isWeb: _isWeb,
                      onClickDelete: (Map<String, dynamic> _comment) async {
                        final bool _deleteComment = await PlatformAlertDialog(
                          title: Strings.deleteComment.i18n,
                          content: Strings.areYouSure.i18n,
                          cancelActionText: Strings.cancel.i18n,
                          defaultActionText: Strings.yes.i18n,
                        ).show(context);
                        if (_deleteComment == true) {
                          await deleteComment(
                            GraphQLProvider.of(context).value,
                            _comment['id'],
                          );
                          callBack();
                        }
                      },
                    )
                  : Container(),
              _showComments || _showAttentions
                  ? Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      height: 1,
                      color: Colors.grey[300],
                    )
                  : Container(),
              _showReactionTotals
                  ? Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      height: 1,
                      color: Colors.grey[300],
                    )
                  : Container(),
              _showReactionTotals
                  ? Container(
                      child: ReactionTable(
                        story: widget.story,
                      ),
                    )
                  : Container(),
              _showMakeComments
                  ? Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      height: 1,
                      color: Colors.grey[300],
                    )
                  : Container(),
              _showMakeComments
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                          Text(Strings.recordAComment.i18n,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(
                            height: 20,
                          ),
                          _isWeb
                              ? RecorderWidgetWeb(
                                  key: Key('staggeredGridTile-${widget.index}'),
                                  isCurrentUserAuthor: true,
                                  setAudioWeb: setCommentAudioWeb,
                                  timerDuration: 90,
                                  showPlayerWidget: false,
                                )
                              : RecorderWidget(
                                  key: Key('staggeredGridTile-${widget.index}'),
                                  isCurrentUserAuthor: true,
                                  setAudioFile: setCommentAudioFile,
                                  timerDuration: 90,
                                ),
                          _uploadInProgress
                              ? CircularProgressIndicator()
                              : Container(),
                          Divider(
                            indent: 50,
                            endIndent: 50,
                            height: 20,
                            thickness: 5,
                          )
                        ])
                  : Container(),
            ],
          ),
        ));
  }
}
