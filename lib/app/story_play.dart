import 'dart:io' as io;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:uuid/uuid.dart';

import 'package:voiceClient/app/sign_in/custom_raised_button.dart';
import 'package:voiceClient/common_widgets/comments.dart';
import 'package:voiceClient/common_widgets/friend_widget.dart';

import 'package:voiceClient/common_widgets/image_controls.dart';
import 'package:voiceClient/common_widgets/platform_alert_dialog.dart';

import 'package:voiceClient/common_widgets/recorder_widget.dart';
import 'package:voiceClient/common_widgets/tags.dart';

import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/constants/keys.dart';
import 'package:voiceClient/constants/mfv.i18n.dart';
import 'package:voiceClient/constants/strings.dart';
import 'package:voiceClient/constants/transparent_image.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/host.dart';
import 'package:voiceClient/services/mutation_service.dart';
import 'package:voiceClient/services/service_locator.dart';
import 'package:voiceClient/services/user_tag_counts.dart';
import 'package:voiceClient/services/logger.dart' as logger;

class StoryPlay extends StatefulWidget {
  const StoryPlay({Key key, this.params}) : super(key: key);
  final Map<String, dynamic> params;

  @override
  _StoryPlayState createState() => _StoryPlayState();
}

class _StoryPlayState extends State<StoryPlay>
    with SingleTickerProviderStateMixin {
  bool _showComments = false;
  Map<String, dynamic> _story;

  List<String> _tags = <String>[];
  List<String> _allTags;

  io.File _image;
  io.File _storyAudio;
  io.File _commentAudio;

  bool _uploadInProgress = false;

  final _uuid = Uuid();
  bool _isCurrentUserAuthor = false;
  bool _showAllTags = false;

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int _width = 200;
  int _height = 200;
  final _spacer = 10;
  DeviceScreenType deviceType;
  bool _showIcons = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    deviceType = getDeviceType(MediaQuery.of(context).size);

    switch (deviceType) {
      case DeviceScreenType.desktop:
      case DeviceScreenType.tablet:
        _width = _height = 750;
        _showIcons = true;
        break;
      case DeviceScreenType.watch:
        _width = _height = 250;
        _showIcons = false;
        break;
      case DeviceScreenType.mobile:
        _width = _height = 300;
        _showIcons = true;
        break;
      default:
        _width = _height = 100;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setCommentAudioFile(io.File audio) {
    setState(() {
      _commentAudio = audio;
    });
  }

  void setStoryAudioFile(io.File audio) {
    setState(() {
      _storyAudio = audio;
    });
  }

  bool tagsHaveChanged() {
    if (_tags.isEmpty && _story == null) {
      return false;
    }
    if (_tags.isNotEmpty && _story == null) {
      return true;
    }
    if (_tags.isNotEmpty && _story['hashtags'].isEmpty) {
      return true;
    }
    OUTER1:
    for (var tag in _tags) {
      bool tagFound = false;
      for (var hashtag in _story['hashtags']) {
        if (hashtag['tag'] == tag) {
          tagFound = true;
          continue OUTER1;
        }
      }
      if (!tagFound) {
        return true;
      }
    }
    for (var hashtag in _story['hashtags']) {
      if (_tags.contains(hashtag['tag'])) {
        continue;
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([
          getStory(),
          getUserHashtagCounts(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            logger.createMessage(
                userEmail: graphQLAuth.getUser().email,
                source: 'story_play',
                shortMessage: snapshot.error.toString(),
                stackTrace: StackTrace.current.toString());
            return Text('\nErrors: \n  ' + snapshot.error.toString());
          } else if (!snapshot.hasData) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          _story = snapshot.data[0];
          _allTags = snapshot.data[1];

          if (_story == null ||
              (_story != null &&
                  _story['user'] != null &&
                  _story['user']['id'] == graphQLAuth.getUserMap()['id'])) {
            _isCurrentUserAuthor = true;
          } else {
            _isCurrentUserAuthor = false;
          }
          if (_story != null && _story['hashtags'] != null) {
            final List<dynamic> hashtags = _story['hashtags'];
            for (var tag in hashtags) {
              if (_tags.contains(tag['tag'])) {
                continue;
              }
              _tags.add(tag['tag']);
            }
          }

          return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
                key: _scaffoldKey,
                appBar: AppBar(
                  title: Text(
                    Strings.MFV.i18n,
                  ),
                  backgroundColor: Color(0xff00bcd4),
                  leading: IconButton(
                      icon: Icon(MdiIcons.lessThan),
                      onPressed: () {
                        if (widget.params.isNotEmpty &&
                            widget.params.containsKey('onFinish')) {
                          widget.params['onFinish']();
                        }
                        Navigator.of(context).pop('upload');
                      }),
                ),
                body: Center(child: getCard(context))),
          );
        });
  }

  Future<Map> getStory() async {
    if (widget.params.isEmpty) {
      return null;
    }
    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(getStoryByIdQL),
      variables: <String, dynamic>{'id': widget.params['id']},
    );
    final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;

    final QueryResult queryResult = await graphQLClient.query(_queryOptions);
    if (queryResult.hasException) {
      throw queryResult.exception;
    }
    final Map<String, dynamic> story = queryResult.data['Story'][0];

    return story;
  }

  Future<void> doStoryUploads() async {
    String _imageFilePath;
    String _audioFilePath;
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

    final GraphQLClient graphQLClientFileServer =
        graphQLAuth.getGraphQLClient(GraphQLClientType.FileServer);

    final GraphQLClient graphQLClientApolloServer =
        graphQLAuth.getGraphQLClient(GraphQLClientType.ApolloServer);

    MultipartFile multipartFile;
    final String _id = _uuid.v1();

    if (_image != null) {
      multipartFile = getMultipartFile(
        _image,
        '$_id.jpg',
        'image',
        'jpeg',
      );

      _imageFilePath = await performMutation(
        graphQLClientFileServer,
        multipartFile,
        'jpeg',
      );
    }

    if (_storyAudio != null) {
      multipartFile = getMultipartFile(
        _storyAudio,
        '$_id.mp3',
        'audio',
        'mp3',
      );

      _audioFilePath = await performMutation(
        graphQLClientFileServer,
        multipartFile,
        'mp3',
      );
    }
    if (_story == null) {
      await addStory(
        graphQLClientApolloServer,
        graphQLAuth.getCurrentUserId(),
        _id,
        _imageFilePath,
        _audioFilePath,
      );

      _tags = _tags.toSet().toList();

      for (var tag in _tags) {
        await addHashTag(
          graphQLClientApolloServer,
          tag,
        );
        await addStoryHashtags(
          graphQLClientApolloServer,
          _id,
          tag,
        );
      }
    } else {
      //don't update unnecessarily
      if (_imageFilePath != null || _audioFilePath != null) {
        _imageFilePath ??= _story['image'];
        _audioFilePath ??= _story['audio'];
        await updateStory(
          graphQLClientApolloServer,
          _story['id'],
          _imageFilePath,
          _audioFilePath,
          _story['created']['formatted'],
        );
      }

      _tags = _tags.toSet().toList();

      if (_tags.isNotEmpty && _story['hashtags'].isEmpty) {
        for (var tag in _tags) {
          await addHashTag(
            graphQLClientApolloServer,
            tag,
          );

          await addStoryHashtags(
            graphQLClientApolloServer,
            _story['id'],
            tag,
          );
        }
      }
      OUTER:
      for (var tag in _tags) {
        //does tag exist in the story
        for (var hashtag in _story['hashtags']) {
          if (hashtag['tag'] == tag) {
            continue OUTER;
          }
          await addHashTag(
            graphQLClientApolloServer,
            tag,
          );

          await addStoryHashtags(
            graphQLClientApolloServer,
            _story['id'],
            tag,
          );
        }
      }

      //does story have tags that were deleted?
      for (var hashtag in _story['hashtags']) {
        if (_tags.contains(hashtag['tag'])) {
          continue;
        }
        await removeStoryHashtags(
          graphQLClientApolloServer,
          _story['id'],
          hashtag['tag'],
        );
      }
    }
    return;
  }

  Future<void> doCommentUploads(BuildContext context) async {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

    final GraphQLClient graphQLClientFileServer =
        graphQLAuth.getGraphQLClient(GraphQLClientType.FileServer);

    final GraphQLClient graphQLClientApolloServer =
        GraphQLProvider.of(context).value;

    final String _commentId = _uuid.v1();

    final MultipartFile multipartFile = getMultipartFile(
      _commentAudio,
      '$_commentId.mp3',
      'audio',
      'mp3',
    );

    final String _audioFilePath = await performMutation(
      graphQLClientFileServer,
      multipartFile,
      'mp3',
    );

    await createComment(
      graphQLClientApolloServer,
      _commentId,
      _story['id'],
      _audioFilePath,
      'new',
    );

    await mergeCommentFrom(
      graphQLClientApolloServer,
      graphQLAuth.getCurrentUserId(),
      _commentId,
    );

    await addStoryComments(
      graphQLClientApolloServer,
      _story['id'],
      _commentId,
    );

    //make sure the updated field gets updated
    await updateStory(
      graphQLClientApolloServer,
      _story['id'],
      _story['image'],
      _story['audio'],
      _story['created']['formatted'],
    );

    await addUserMessages(
      graphQLClientApolloServer,
      graphQLAuth.getCurrentUserId(),
      _story['user']['id'],
      _uuid.v1(),
      'new',
      'Comment',
      'comment',
      _story['id'],
    );
    return;
  }

  Widget _buildUploadButton(BuildContext context) {
    return _uploadInProgress
        ? CircularProgressIndicator()
        : CustomRaisedButton(
            key: Key(Keys.commentsUploadButton),
            icon: Icon(
              Icons.file_upload,
              color: Colors.white,
            ),
            text: Strings.upload.i18n,
            onPressed: () async {
              setState(() {
                _uploadInProgress = true;
              });
              await doCommentUploads(context);
              setState(() {
                _commentAudio = null;
                _uploadInProgress = false;
              });

              //Navigator.pop(context);
            },
          );
  }

  Widget _buildUploadStoryButton(BuildContext context) {
    return _uploadInProgress
        ? CircularProgressIndicator()
        : CustomRaisedButton(
            key: Key(Keys.storyPageUploadButton),
            icon: Icon(
              Icons.file_upload,
              color: Colors.white,
            ),
            text: Strings.upload.i18n,
            onPressed: () async {
              setState(() {
                _uploadInProgress = true;
              });
              await doStoryUploads();
              setState(() {
                _uploadInProgress = false;
              });
            },
          );
  }

  Widget getImageControls(bool _showIcons) {
    if (!_isCurrentUserAuthor) {
      return Container();
    }
    final ImageControls _imageControls =
        ImageControls(onImageSelected: (File croppedFile) {
      setState(() {
        _image = croppedFile;
      });
    });
    return Card(
      margin: EdgeInsets.all(0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            Strings.imageSelection.i18n,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 8,
          ),
          _imageControls.buildImageControls(showIcons: _showIcons),
          SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget getPlayerControls(int width, bool showIcons) {
    return _story == null
        ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RecorderWidget(
                isCurrentUserAuthor: _isCurrentUserAuthor,
                setAudioFile: setStoryAudioFile,
                width: width,
              )
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _isCurrentUserAuthor
                  ? SizedBox(
                      height: 8,
                    )
                  : Container(),
              _isCurrentUserAuthor
                  ? RecorderWidget(
                      isCurrentUserAuthor: _isCurrentUserAuthor,
                      setAudioFile: setStoryAudioFile,
                      width: width,
                      url: host(_story['audio']),
                    )
                  : Container(),
            ],
          );
  }

  Widget getImageDisplay(int _width, int _height) {
    if (_image != null)
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25.0),
          child: Image.file(
            _image,
            width: _width.toDouble(),
            height: _height.toDouble(),
          ),
        ),
      );
    else if (_story != null)
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25.0),
          child: FadeInImage.memoryNetwork(
            width: _width.toDouble(),
            height: _height.toDouble(),
            placeholder: kTransparentImage,
            image: host(
              _story['image'],
              width: _width,
              height: _height,
              resizingType: 'fill',
              enlarge: 1,
            ),
          ),
        ),
      );
    else
      return Stack(
        children: <Widget>[
          Image(
            image: AssetImage('assets/placeholder.png'),
            width: _width.toDouble(),
            height: _height.toDouble(),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(25.0),
            child: Container(
              height: _height.toDouble(),
              width: _width.toDouble(),
              padding: EdgeInsets.all(5.0),
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withAlpha(30),
                    Colors.black12,
                    Colors.black54
                  ],
                ),
              ),
              child: Text(
                Strings.imagePlaceholder.i18n,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
        ],
      );
  }

  Widget buildDeleteStory(bool _showIcons) {
    return Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          CustomRaisedButton(
            key: Key(Keys.deleteStoryButton),
            text: Strings.deleteStoryButton.i18n,
            icon: _showIcons
                ? Icon(
                    Icons.delete,
                    color: Colors.white,
                  )
                : null,
            onPressed: () async {
              final bool _deleteStory = await PlatformAlertDialog(
                title: Strings.deleteStoryQuestion.i18n,
                content: Strings.areYouSure.i18n,
                cancelActionText: Strings.cancel.i18n,
                defaultActionText: Strings.yes.i18n,
              ).show(context);
              if (_deleteStory == true) {
                for (var _comment in _story['comments']) {
                  await removeStoryComment(
                    GraphQLProvider.of(context).value,
                    _story['id'],
                    _comment['id'],
                  );

                  await deleteComment(
                    GraphQLProvider.of(context).value,
                    _comment['id'],
                  );
                }

                for (var hashtag in _story['hashtags']) {
                  await removeStoryHashtags(
                    GraphQLProvider.of(context).value,
                    _story['id'],
                    hashtag['tag'],
                  );
                }

                await deleteStory(
                  GraphQLProvider.of(context).value,
                  _story['id'],
                );

                widget.params['onDelete']();
                Navigator.of(context).pop();
              }
            },
          )
        ],
      ),
    );
  }

  Widget getStoryControls() {
    return Column(children: [
      if (_story != null &&
              (_image != null || _storyAudio != null || tagsHaveChanged()) ||
          (_story == null && _image != null && _storyAudio != null))
        _buildUploadStoryButton(context),
      if (_image != null || _storyAudio != null)
        SizedBox(
          height: _spacer.toDouble(),
        ),
      getImageControls(_showIcons),
      SizedBox(
        height: _spacer.toDouble(),
      ),
      getPlayerControls(_width, _showIcons),
      Divider(
        height: _spacer.toDouble(),
        thickness: 2,
      ),
      SizedBox(
        height: 8,
      ),
      Text(Strings.tagsLabel.i18n,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          )),
      getTags(
        allTags: _allTags,
        tags: _tags,
        onTagAdd: (String tag) {
          setState(() {
            _tags.add(tag);
          });
        },
        onTagRemove: (int index) {
          setState(() {
            _tags.removeAt(index);
          });
        },
        updatedAble: _isCurrentUserAuthor,
      ),
      SizedBox(
        height: _spacer.toDouble(),
      ),
      _isCurrentUserAuthor
          ? Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Text(Strings.showAllTags.i18n,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Checkbox(
                    value: _showAllTags,
                    onChanged: (bool show) {
                      if (show) {
                        _allTags.forEach(_tags.add);
                      } else {
                        _allTags.forEach(_tags.remove);
                      }
                      setState(() {
                        _showAllTags = !_showAllTags;
                      });
                    },
                  ),
                ],
              ),
            )
          : Container(),
      Divider(
        indent: 50,
        endIndent: 50,
        height: _spacer.toDouble(),
        thickness: 5,
      ),
      SizedBox(
        height: _spacer.toDouble(),
      )
    ]);
  }

  Widget getCard(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.params != null &&
                widget.params['id'] != null &&
                widget.params['id'].isNotEmpty)
              buildFriend(
                context,
                _story['user'],
              ),
            if (widget.params != null &&
                widget.params['id'] != null &&
                widget.params['id'].isNotEmpty &&
                _isCurrentUserAuthor &&
                _showComments == false)
              buildDeleteStory(_showIcons),
            SizedBox(height: _spacer.toDouble()),
            getImageDisplay(
              _width,
              _height,
            ),
            SizedBox(
              height: _spacer.toDouble(),
            ),
            _showComments == false ? getStoryControls() : Container(),
            _story != null
                ? Column(children: <Widget>[
                    InkWell(
                        child: _showComments
                            ? Text(
                                Strings.storyLabel.i18n,
                                style: TextStyle(
                                  color: Color(0xff00bcd4),
                                  fontSize: 16.0,
                                ),
                              )
                            : Text(
                                Strings.commentsLabel.i18n,
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
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                Text(Strings.recordAComment.i18n,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                SizedBox(
                                  height: _spacer.toDouble(),
                                ),
                                RecorderWidget(
                                  isCurrentUserAuthor: true,
                                  setAudioFile: setCommentAudioFile,
                                  timerDuration: 90,
                                ),
                                if (_commentAudio != null)
                                  _buildUploadButton(context),
                                Divider(
                                  indent: 50,
                                  endIndent: 50,
                                  height: _spacer.toDouble(),
                                  thickness: 5,
                                ),
                                Comments(
                                  key: Key(Keys.commentsWidgetExpansionTile),
                                  story: _story,
                                  fontSize: 16,
                                  showExpand: true,
                                  onClickDelete:
                                      (Map<String, dynamic> _comment) async {
                                    final bool _deleteComment =
                                        await PlatformAlertDialog(
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
                                      setState(() {});
                                    }
                                  },
                                )
                              ])
                        : Container()
                  ])
                : Container(),
            SizedBox(
              height: 75,
            ),
          ],
        ),
      ),
    );
  }
}
