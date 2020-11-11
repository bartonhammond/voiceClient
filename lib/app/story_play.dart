import 'dart:io' as io;

import 'package:MyFamilyVoice/app/sign_in/custom_raised_button.dart';
import 'package:MyFamilyVoice/common_widgets/comments.dart';
import 'package:MyFamilyVoice/common_widgets/friend_widget.dart';
import 'package:MyFamilyVoice/common_widgets/image_controls.dart';
import 'package:MyFamilyVoice/common_widgets/platform_alert_dialog.dart';
import 'package:MyFamilyVoice/common_widgets/recorder_widget.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:MyFamilyVoice/constants/keys.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/constants/transparent_image.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/host.dart';
import 'package:MyFamilyVoice/services/logger.dart' as logger;
import 'package:MyFamilyVoice/services/mutation_service.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:uuid/uuid.dart';

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

  io.File _image;
  io.File _storyAudio;
  io.File _commentAudio;

  String _imageFilePath;
  String _audioFilePath;
  StoryType _storyType = StoryType.FAMILY;
  bool _uploadInProgress = false;

  final _uuid = Uuid();
  String _id;

  bool _isCurrentUserAuthor = false;

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int _width = 200;
  int _height = 200;
  final _spacer = 10;
  DeviceScreenType deviceType;
  bool _showIcons = false;

  @override
  void initState() {
    _id = _uuid.v1();

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

  Future<void> setCommentAudioFile(io.File audio) async {
    if (audio == null) {
      return;
    }
    setState(() {
      _commentAudio = audio;
      _uploadInProgress = true;
    });
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

    final GraphQLClient graphQLClientFileServer =
        graphQLAuth.getGraphQLClient(GraphQLClientType.FileServer);

    final GraphQLClient graphQLClientApolloServer =
        GraphQLProvider.of(context).value;
    await doCommentUploads(
      graphQLAuth,
      graphQLClientFileServer,
      graphQLClientApolloServer,
      _commentAudio,
      _story,
    );
    setState(() {
      _commentAudio = null;
      _uploadInProgress = false;
    });
    Flushbar<dynamic>(
      message: Strings.saved.i18n,
      duration: Duration(seconds: 3),
    )..show(_scaffoldKey.currentContext);
    return;
  }

  Future<void> setStoryAudioFile(io.File audio) async {
    setState(() {
      _storyAudio = audio;
      _uploadInProgress = true;
    });

    await doAudioUpload();

    setState(() {
      _uploadInProgress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([
          getStory(),
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
              key: _scaffoldKey,
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          _story = snapshot.data[0];
          if (_story == null) {
            _storyType ??= StoryType.FAMILY;
          } else {
            switch (_story['type']) {
              case 'FAMILY':
                _storyType = StoryType.FAMILY;
                break;
              case 'FRIENDS':
                _storyType = StoryType.FRIENDS;
                break;
              case 'GLOBAL':
                _storyType = StoryType.GLOBAL;
                break;
            }
          }

          if (_story == null ||
              (_story != null &&
                  _story['user'] != null &&
                  _story['user']['id'] == graphQLAuth.getUserMap()['id'])) {
            _isCurrentUserAuthor = true;
          } else {
            _isCurrentUserAuthor = false;
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
              body: Center(
                child: getCard(context),
              ),
            ),
          );
        });
  }

  Future<Map> getStory() async {
    if (widget.params.isEmpty) {
      return null;
    }
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(getStoryByIdQL),
      variables: <String, dynamic>{
        'id': widget.params['id'],
        'email': graphQLAuth.getUserMap()['email']
      },
    );
    final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;

    final QueryResult queryResult = await graphQLClient.query(_queryOptions);
    if (queryResult.hasException) {
      throw queryResult.exception;
    }
    final Map<String, dynamic> story = queryResult.data['Story'][0];

    return story;
  }

  Future<void> doImageUpload() async {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

    final GraphQLClient graphQLClientFileServer =
        graphQLAuth.getGraphQLClient(GraphQLClientType.FileServer);

    MultipartFile multipartFile;

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
    await doStoryUpload();
    return;
  }

  Future<void> doAudioUpload() async {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

    final GraphQLClient graphQLClientFileServer =
        graphQLAuth.getGraphQLClient(GraphQLClientType.FileServer);

    MultipartFile multipartFile;

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
    await doStoryUpload();
    return;
  }

  Future<void> doStoryUpload() async {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

    final GraphQLClient graphQLClientApolloServer =
        graphQLAuth.getGraphQLClient(GraphQLClientType.ApolloServer);

    if (_story == null) {
      if (_imageFilePath != null && _audioFilePath != null) {
        await addStory(
          graphQLClientApolloServer,
          graphQLAuth.getCurrentUserId(),
          _id,
          _imageFilePath,
          _audioFilePath,
          storyTypes[_storyType.index],
        );
        Flushbar<dynamic>(
          message: Strings.saved.i18n,
          duration: Duration(seconds: 3),
        )..show(_scaffoldKey.currentContext);
      }
    } else {
      //don't update unnecessarily
      if (_imageFilePath != null ||
          _audioFilePath != null ||
          _storyType != _story['type']) {
        _imageFilePath ??= _story['image'];
        _audioFilePath ??= _story['audio'];
        await updateStory(
          graphQLClientApolloServer,
          _story['id'],
          _imageFilePath,
          _audioFilePath,
          _story['created']['formatted'],
          storyTypes[_storyType.index],
        );
        Flushbar<dynamic>(
          message: Strings.saved.i18n,
          duration: Duration(seconds: 3),
        )..show(_scaffoldKey.currentContext);
      }
    }

    return;
  }

  Widget getImageControls(bool _showIcons) {
    if (!_isCurrentUserAuthor) {
      return Container();
    }
    final ImageControls _imageControls =
        ImageControls(onImageSelected: (io.File croppedFile) async {
      setState(() {
        _image = croppedFile;
        _uploadInProgress = true;
      });

      await doImageUpload();

      setState(() {
        _uploadInProgress = false;
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
              RecorderWidget(
                isCurrentUserAuthor: _isCurrentUserAuthor,
                setAudioFile: setStoryAudioFile,
                width: width,
                url: host(_story['audio']),
              )
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
                final String id = _story['id'];
                await deleteStory(
                  GraphQLProvider.of(context).value,
                  id,
                );
                await deleteMessage(
                  GraphQLProvider.of(context).value,
                  id,
                );

                if (widget.params.isNotEmpty &&
                    widget.params.containsKey('onDelete')) {
                  widget.params['onDelete']();
                }
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
      _uploadInProgress ? CircularProgressIndicator() : Container(),
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
        indent: 50,
        endIndent: 50,
        height: _spacer.toDouble(),
        thickness: 5,
      ),
    ]);
  }

  Widget getStoryTypeDropDown() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Audiance:',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: 10,
          ),
          DropdownButton<StoryType>(
              value: _storyType,
              items: const [
                DropdownMenuItem(
                  child: Text('Friends', style: TextStyle(fontSize: 15)),
                  value: StoryType.FRIENDS,
                ),
                DropdownMenuItem(
                  child: Text('Family', style: TextStyle(fontSize: 15)),
                  value: StoryType.FAMILY,
                ),
                DropdownMenuItem(
                    child: Text('Global', style: TextStyle(fontSize: 15)),
                    value: StoryType.GLOBAL),
              ],
              onChanged: (_value) async {
                setState(() {
                  _storyType = _value;
                });
                await doStoryUpload();
              })
        ],
      ),
    );
  }

  Widget getCard(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.params != null &&
                widget.params['id'] != null &&
                widget.params['id'].isNotEmpty)
              FriendWidget(
                user: _story['user'],
                story: _story,
                showMessage: false,
              ),
            if (widget.params != null &&
                widget.params['id'] != null &&
                widget.params['id'].isNotEmpty &&
                _isCurrentUserAuthor &&
                _showComments == false)
              buildDeleteStory(_showIcons),
            getStoryTypeDropDown(),
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
                    SizedBox(
                      height: _spacer.toDouble(),
                    ),
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
                    SizedBox(
                      height: _spacer.toDouble(),
                    ),
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
                                  isCurrentUserAuthor: _isCurrentUserAuthor,
                                  setAudioFile: setCommentAudioFile,
                                  timerDuration: 90,
                                ),
                                _uploadInProgress
                                    ? CircularProgressIndicator()
                                    : Divider(
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
