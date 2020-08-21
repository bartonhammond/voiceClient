import 'dart:io' as io;
import 'dart:io';

import 'package:http/http.dart';

import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:uuid/uuid.dart';
import 'package:voiceClient/app/sign_in/custom_raised_button.dart';

import 'package:voiceClient/common_widgets/comments.dart';
import 'package:voiceClient/common_widgets/image_controls.dart';
import 'package:voiceClient/common_widgets/player_widget.dart';
import 'package:voiceClient/common_widgets/recorder_widget.dart';
import 'package:voiceClient/common_widgets/tags.dart';
import 'package:voiceClient/constants/constants.dart';

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

class StoryPlay extends StatefulWidget {
  const StoryPlay({Key key, this.params}) : super(key: key);
  final Map<String, dynamic> params;

  @override
  _StoryPlayState createState() => _StoryPlayState();
}

class _StoryPlayState extends State<StoryPlay> {
  Map<String, dynamic> story;
  List<String> allTags;

  io.File _audio;
  io.File _storyAudio;

  io.File _image;
  bool _uploadInProgress = false;
  var uuid = Uuid();
  bool _isCurrentUserAuthor = false;

  void setAudioFile(io.File audio) {
    setState(() {
      _audio = audio;
    });
  }

  void setStoryAudioFile(io.File audio) {
    setState(() {
      _storyAudio = audio;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        getStory(),
        getUserHashtagCounts(context),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          story = snapshot.data[0];
          allTags = snapshot.data[1];
          if (story['user']['id'] == graphQLAuth.getUserMap()['id']) {
            _isCurrentUserAuthor = true;
          } else {
            _isCurrentUserAuthor = false;
          }
          print('got story and allTags');
          return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  Strings.MFV.i18n,
                ),
                backgroundColor: Color(0xff00bcd4),
                leading: IconButton(
                    icon: Icon(MdiIcons.lessThan),
                    onPressed: () {
                      widget.params['onFinish']();
                      Navigator.of(context).pop('upload');
                    }),
              ),
              //drawer: getDrawer(context),
              body: _buildPage(context),
            ),
          );
        }
      },
    );
  }

  Future<Map> getStory() async {
    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(getStoryByIdQL),
      variables: <String, dynamic>{'id': widget.params['id']},
    );
    final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;

    final QueryResult queryResult = await graphQLClient.query(_queryOptions);
    final Map<String, dynamic> story = queryResult.data['Story'][0];

    return story;
  }

  Widget buildFriend(Map<String, dynamic> story) {
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
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 5,
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: FadeInImage.memoryNetwork(
                height: _height.toDouble(),
                width: _width.toDouble(),
                placeholder: kTransparentImage,
                image: host(story['user']['image'],
                    width: _width,
                    height: _height,
                    resizingType: 'fill',
                    enlarge: 1),
              ),
            ),
          ),
          Text(
            story['user']['name'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          Text(
            story['user']['home'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          Text(
            story['user']['birth'].toString(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }

  Future<void> doUploads(BuildContext context) async {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

    final GraphQLClient graphQLClientFileServer =
        graphQLAuth.getGraphQLClient(GraphQLClientType.FileServer);

    final GraphQLClient graphQLClientApolloServer =
        GraphQLProvider.of(context).value;

    final String _commentId = uuid.v1();

    final MultipartFile multipartFile = getMultipartFile(
      _audio,
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
      story['id'],
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
      story['id'],
      _commentId,
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
              await doUploads(context);
              setState(() {
                _audio = null;
                _uploadInProgress = false;
              });

              //Navigator.pop(context);
            },
          );
  }

  Widget _buildPage(BuildContext context) {
    final tags = <String>[];
    final List<dynamic> hashtags = story['hashtags'];
    for (var tag in hashtags) {
      tags.add(tag['tag']);
    }
    return Center(
        child: ListView(
      shrinkWrap: true,
      children: <Widget>[
        getCard(tags),
      ],
    ));
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
              await doUploads(context);
              setState(() {
                _image = null;
                _audio = null;
                _uploadInProgress = false;
              });
              //pop back to tab for stories

              Navigator.pop(context);
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

  Widget getPlayerControls(int width) {
    if (!_isCurrentUserAuthor) {
      return PlayerWidget(
        url: host(story['audio']),
        width: width,
      );
    } else {
      return RecorderWidget(
        id: UniqueKey().toString(),
        setAudioFile: setStoryAudioFile,
      );
    }
  }

  Widget getCard(
    List<String> tags,
  ) {
    final DeviceScreenType deviceType =
        getDeviceType(MediaQuery.of(context).size);
    int _width = 200;
    int _height = 200;
    const _spacer = 10;
    bool _showIcons = true;
    switch (deviceType) {
      case DeviceScreenType.desktop:
      case DeviceScreenType.tablet:
        _width = _height = 750;

        break;
      case DeviceScreenType.watch:
        _width = _height = 250;
        _showIcons = false;
        break;
      case DeviceScreenType.mobile:
        _width = _height = 300;
        break;
      default:
        _width = _height = 100;
    }
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          margin: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              buildFriend(story),
              if (_image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(75.0),
                  child: Image.file(
                    _image,
                    width: _width.toDouble(),
                    height: _height.toDouble(),
                  ),
                )
              else
                Container(
                  width: _width.toDouble(),
                  height: _height.toDouble(),
                  margin: EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25.0),
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: host(
                        story['image'],
                        width: _width,
                        height: _height,
                      ),
                    ),
                  ),
                ),
              SizedBox(
                height: _spacer.toDouble(),
              ),
              if (_image != null || _storyAudio != null)
                _buildUploadStoryButton(context),
              if (_image != null || _storyAudio != null)
                SizedBox(
                  height: _spacer.toDouble(),
                ),
              getImageControls(_showIcons),
              SizedBox(
                height: _spacer.toDouble(),
              ),
              getPlayerControls(_width),
              Divider(
                height: _spacer.toDouble(),
                thickness: 2,
              ),
              SizedBox(
                height: _spacer.toDouble(),
              ),
              Text(Strings.tagsLabel.i18n,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  )),
              TagsWidget(
                allTags: allTags,
                tags: tags,
                updatedAble: _isCurrentUserAuthor,
              ),
              SizedBox(
                height: 8,
              ),
              Divider(
                indent: 50,
                endIndent: 50,
                height: _spacer.toDouble(),
                thickness: 5,
              ),
              SizedBox(
                height: _spacer.toDouble(),
              ),
              Text(Strings.recordAComment.i18n,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(
                height: _spacer.toDouble(),
              ),
              RecorderWidget(
                id: story['id'],
                setAudioFile: setAudioFile,
                timerDuration: 90,
              ),
              if (_audio != null) _buildUploadButton(context),
              Divider(
                indent: 50,
                endIndent: 50,
                height: _spacer.toDouble(),
                thickness: 5,
              ),
              Text(Strings.commentsLabel.i18n,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Comments(
                key: Key(Keys.commentsWidgetExpansionTile),
                story: story,
                fontSize: 16,
                showExpand: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
