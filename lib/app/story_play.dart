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

import 'package:voiceClient/common_widgets/image_controls.dart';
import 'package:voiceClient/common_widgets/player_widget.dart';
import 'package:voiceClient/common_widgets/recorder_widget.dart';

import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/constants/keys.dart';
import 'package:voiceClient/constants/mfv.i18n.dart';
import 'package:voiceClient/constants/strings.dart';
import 'package:voiceClient/constants/transparent_image.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/graphql_client.dart';
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

class _StoryPlayState extends State<StoryPlay>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic> story;
  List<String> tags = <String>[];
  List<String> allTags;

  io.File _image;
  io.File _storyAudio;
  io.File _commentAudio;

  String _imageFilePath;
  String _audioFilePath;

  bool _uploadInProgress = false;

  var uuid = Uuid();
  bool _isCurrentUserAuthor = false;

  final _formKey = GlobalKey<FormState>();
  final className = TextEditingController();

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
          return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
                key: _scaffoldKey,
                resizeToAvoidBottomInset: false,
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
                body: Center(child: getCard(context))),
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

  Future<void> doStoryUploads(BuildContext context) async {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

    final GraphQLClient graphQLClientFileServer =
        graphQLAuth.getGraphQLClient(GraphQLClientType.FileServer);

    final GraphQLClient graphQLClientApolloServer =
        getGraphQLClient(context, GraphQLClientType.ApolloServer);

    final String _id = uuid.v1();
    MultipartFile multipartFile = getMultipartFile(
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

    await addStory(
      graphQLClientApolloServer,
      graphQLAuth.getCurrentUserId(),
      _id,
      _imageFilePath,
      _audioFilePath,
      daysOffset: 0,
    );

    tags = tags.toSet().toList();

    for (var tag in tags) {
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
    return;
  }

  Future<void> doCommentUploads(BuildContext context) async {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

    final GraphQLClient graphQLClientFileServer =
        graphQLAuth.getGraphQLClient(GraphQLClientType.FileServer);

    final GraphQLClient graphQLClientApolloServer =
        GraphQLProvider.of(context).value;

    final String _commentId = uuid.v1();

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
              await doStoryUploads(context);
              setState(() {
                _image = null;
                _storyAudio = null;
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

  Widget getImageDisplay(int _width, int _height) {
    if (_image != null)
      return ClipRRect(
        borderRadius: BorderRadius.circular(75.0),
        child: Image.file(
          _image,
          width: _width.toDouble(),
          height: _height.toDouble(),
        ),
      );
    else if (story != null)
      return Container(
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

  Widget getCard(BuildContext context) {
    final List<dynamic> hashtags = story['hashtags'];
    for (var tag in hashtags) {
      tags.add(tag['tag']);
    }
    bool _showAllTags = false;
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
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.params != null &&
                widget.params['id'] != null &&
                widget.params['id'].isNotEmpty)
              buildFriend(story),
            getImageDisplay(
              _width,
              _height,
            ),
            SizedBox(
              height: _spacer.toDouble(),
            ),
            Text(Strings.tagsLabel.i18n,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                )),
            Container(
              width: 350,
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: className,
                autocorrect: true,
                decoration: InputDecoration(hintText: 'Enter Your Class Here'),
              ),
            ),
            /*getTags(
            allTags: allTags,
            tags: tags,
            onTagAdd: (String tag) {
              tags.add(tag);
            },
            onTagRemove: (index) {
              tags.removeAt(index);
            },
            updatedAble: _isCurrentUserAuthor,
          ),*/
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
              height: 8,
            ),
            Container(
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
                        allTags.forEach(tags.add);
                      } else {
                        allTags.forEach(tags.remove);
                      }
                      setState(() {
                        _showAllTags = !_showAllTags;
                      });
                    },
                  ),
                  Divider(
                    color: Colors.blueGrey,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(''),
                  ),
                ],
              ),
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
              setAudioFile: setCommentAudioFile,
              timerDuration: 90,
            ),
            if (_commentAudio != null) _buildUploadButton(context),
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
    );
  }
}
