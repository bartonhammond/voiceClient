import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:MyFamilyVoice/common_widgets/radio_group.dart';
import 'package:MyFamilyVoice/ql/story/story_comments.dart';
import 'package:MyFamilyVoice/ql/story/story_original_user.dart';
import 'package:MyFamilyVoice/ql/story/story_search.dart';
import 'package:MyFamilyVoice/ql/story/story_tags.dart';
import 'package:MyFamilyVoice/ql/story/story_user.dart';
import 'package:MyFamilyVoice/ql/story_ql.dart';
import 'package:MyFamilyVoice/app/sign_in/custom_raised_button.dart';
import 'package:MyFamilyVoice/app_config.dart';
import 'package:MyFamilyVoice/common_widgets/comments.dart';
import 'package:MyFamilyVoice/common_widgets/friend_widget.dart';
import 'package:MyFamilyVoice/common_widgets/image_controls.dart';
import 'package:MyFamilyVoice/common_widgets/platform_alert_dialog.dart';
import 'package:MyFamilyVoice/common_widgets/recorder_widget.dart';
import 'package:MyFamilyVoice/common_widgets/recorder_widget_web.dart';
import 'package:MyFamilyVoice/common_widgets/tag_friends_page.dart';
import 'package:MyFamilyVoice/common_widgets/tagged_friends.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/keys.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/constants/transparent_image.dart';
import 'package:MyFamilyVoice/services/eventBus.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/host.dart';
import 'package:MyFamilyVoice/services/logger.dart' as logger;
import 'package:MyFamilyVoice/services/mutation_service.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:uuid/uuid.dart';
import 'package:http_parser/http_parser.dart';

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
  final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
  ByteData _image;
  io.File _storyAudio;
  io.File _commentAudio;
  ByteData _webImageBytes;

  Uint8List _storyAudioWeb;
  Uint8List _commentAudioWeb;

  String _imageFilePath;
  String _audioFilePath;
  StoryType _storyType = StoryType.FRIENDS;
  bool _uploadInProgress = false;
  bool _isWeb = false;

  final _uuid = Uuid();
  String _id;
  bool _storyWasSaved = false;

  bool _isCurrentUserAuthor = false;
  bool _showTaggedFriends = false;

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int _width = 200;
  int _height = 200;
  final _spacer = 10;
  DeviceScreenType deviceType;
  bool _showIcons = false;

  GraphQLClient graphQLClient;
  GraphQLClient graphQLClientFileServer;
  FToast _fToast;

  @override
  void initState() {
    _id = _uuid.v1();

    _fToast = FToast();
    _fToast.init(context);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    deviceType = getDeviceType(MediaQuery.of(context).size);

    switch (deviceType) {
      case DeviceScreenType.desktop:
      case DeviceScreenType.tablet:
        _width = _height = 400;
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

  void _showToast() {
    if (!mounted) {
      return;
    }
    final Widget toast = Container(
      key: Key('toastContainer'),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.black,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text(Strings.saved.i18n,
              key: Key('storyPlayToast'),
              style: TextStyle(
                  backgroundColor: Colors.black,
                  color: Colors.white,
                  fontSize: 16.0))
        ],
      ),
    );

    _fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 3),
    );
  }

  Future<void> setBook(Map<String, dynamic> user) async {
    if (user == null) {
      //remove the current book
      await changeStoriesUser(
        graphQLClient,
        currentUserId: _story['user']['id'], //currentUser
        newUserId: _story['originalUser']['id'], //original
        storyId: _story['id'],
      );
    } else {
      if (_story['originalUser'] == null) {
        //Merge Story w/ OriginalUser
        await changeStoryUserAndSaveOriginalUser(
          graphQLClient,
          currentUserId: _story['user']['id'],
          storyId: _story['id'],
          newUserId: user['id'],
        );
      } else {
        await changeStoriesUser(
          graphQLClient,
          currentUserId: _story['user']['id'], //currentUser
          newUserId: user['id'], //new
          storyId: _story['id'],
        );
      }

      await addUserMessages(
        graphQLClient: graphQLClient,
        fromUser: graphQLAuth.getUserMap(),
        toUser: user,
        messageId: _uuid.v1(),
        status: 'new',
        type: 'book',
        key: _story['id'],
      );
    }
    eventBus.fire(StoryWasAssignedToBook());

    setState(() {});
  }

  Future<void> setCommentAudioFile(io.File audio) async {
    if (audio == null) {
      return;
    }
    setState(() {
      _commentAudio = audio;
      _uploadInProgress = true;
    });

    await doCommentUploads(
      graphQLAuth,
      graphQLClientFileServer,
      GraphQLProvider.of(context).value,
      _story,
      commentAudio: _commentAudio,
    );
    setState(() {
      _commentAudio = null;
      _uploadInProgress = false;
    });

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

    await doCommentUploads(
      graphQLAuth,
      graphQLClientFileServer,
      GraphQLProvider.of(context).value,
      _story,
      commentAudioWeb: _commentAudioWeb,
    );

    setState(() {
      _commentAudio = null;
      _uploadInProgress = false;
    });
    _showToast();
    return;
  }

  Future<void> setStoryAudioFile(io.File audio) async {
    if (audio == null) {
      return;
    }
    setState(() {
      _storyAudio = audio;
      _uploadInProgress = true;
    });

    await doAudioUpload();

    setState(() {
      _uploadInProgress = false;
    });
  }

  Future<void> setStoryAudioWeb(Uint8List bytes) async {
    if (bytes == null) {
      return;
    }
    setState(() {
      _storyAudioWeb = bytes;
      _uploadInProgress = true;
    });

    await doAudioUpload();

    setState(() {
      _uploadInProgress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isWeb = AppConfig.of(context).isWeb;
    graphQLClient = GraphQLProvider.of(context).value;
    graphQLClientFileServer =
        graphQLAuth.getGraphQLClient(GraphQLClientType.FileServer);

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
            }
          }
          //new story?
          if (_story == null ||
              (_story != null &&
                  _story['user'] != null &&
                  //story written by currentUser
                  (_story['user']['id'] == graphQLAuth.getUserMap()['id'] ||
                      //story is book and the original user is currentUser
                      _story['user']['isBook'] == true &&
                          _story['originalUser']['id'] ==
                              graphQLAuth.getUserMap()['id']))) {
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
                    key: Key('backButton'),
                    icon: Icon(MdiIcons.lessThan),
                    onPressed: () {
                      if (widget.params.isNotEmpty &&
                          widget.params.containsKey('onFinish')) {
                        widget.params['onFinish']();
                      }
                      Navigator.of(context).pop();
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
    if (!(_storyWasSaved ||
        (widget.params != null &&
            widget.params.isNotEmpty &&
            widget.params.containsKey('id')))) {
      return null;
    }

    final StoryTags storyTags = StoryTags();
    final StoryUser storyUser = StoryUser();
    final StoryOriginalUser storyOriginalUser = StoryOriginalUser();
    final StoryComments storyComments = StoryComments();
    final StoryQl storyQl = StoryQl(
      storyTags: storyTags,
      storyUser: storyUser,
      storyOriginalUser: storyOriginalUser,
      storyComments: storyComments,
    );

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
    return await storySearch.getItem(<String, dynamic>{
      'id': _storyWasSaved ? _id : widget.params['id'],
      'currentUserEmail': graphQLAuth.getUserMap()['email']
    });
  }

  Future<void> doImageUpload() async {
    MultipartFile multipartFile;

    if (_image != null) {
      multipartFile = MultipartFile.fromBytes(
        'image',
        _image.buffer.asUint8List(0, _image.lengthInBytes),
        filename: '$_id.jpg',
        contentType: MediaType('image', 'jpeg'),
      );

      _imageFilePath = await performMutation(
        graphQLClientFileServer,
        multipartFile,
        'jpeg',
      );
    } else if (_isWeb && _webImageBytes != null) {
      multipartFile = MultipartFile.fromBytes(
        'image',
        _webImageBytes.buffer.asUint8List(0, _webImageBytes.lengthInBytes),
        filename: '$_id.jpg',
        contentType: MediaType('image', 'jpeg'),
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
    MultipartFile multipartFile;

    if (_storyAudioWeb != null) {
      multipartFile = MultipartFile.fromBytes(
        'audio',
        _storyAudioWeb,
        filename: '$_id.mp3',
        contentType: MediaType('audio', 'mp3'),
      );
    }

    if (_storyAudio != null) {
      multipartFile = getMultipartFile(
        _storyAudio,
        '$_id.mp3',
        'audio',
        'mp3',
      );
    }
    if (multipartFile != null) {
      _audioFilePath = await performMutation(
        graphQLClientFileServer,
        multipartFile,
        'mp3',
      );
      _showToast();

      await doStoryUpload();
    }

    return;
  }

  Future<void> doStoryUpload() async {
    final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;
    if (_story == null) {
      if (_imageFilePath != null && _audioFilePath != null) {
        await addStory(
          graphQLClient,
          currentUserId: graphQLAuth.getUserMap()['id'],
          storyId: _id,
          imageFilePath: _imageFilePath,
          audioFilePath: _audioFilePath,
          type: storyTypes[_storyType.index],
        );
        _showToast();
        setState(() {
          _storyWasSaved = true;
        });
      }
    } else {
      //don't update unnecessarily
      if (_imageFilePath != null ||
          _audioFilePath != null ||
          _storyType != _story['type']) {
        _imageFilePath ??= _story['image'];
        _audioFilePath ??= _story['audio'];
        await updateStory(
          graphQLClient,
          _story['id'],
          _imageFilePath,
          _audioFilePath,
          _story['created']['formatted'],
          storyTypes[_storyType.index],
        );
        _showToast();
      }
    }

    return;
  }

  Widget getImageControls(bool _showIcons) {
    if (!_isCurrentUserAuthor) {
      return Container();
    }

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
          ImageControls(
              showIcons: _showIcons,
              isWeb: _isWeb,
              onOpenFileExplorer: (bool opening) {
                setState(() {
                  _uploadInProgress = opening;
                });
              },
              onWebCroppedCallback: (ByteData imageBytes) async {
                setState(() {
                  _webImageBytes = imageBytes;
                  _uploadInProgress = true;
                });

                await doImageUpload();

                setState(() {
                  _uploadInProgress = false;
                });
              },
              onImageSelected: (ByteData bytes) async {
                setState(() {
                  _image = bytes;
                  _uploadInProgress = true;
                });

                await doImageUpload();

                setState(() {
                  _uploadInProgress = false;
                });
              }),
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
              _isWeb
                  ? RecorderWidgetWeb(
                      key: Key('storyPlayRecorderWidgetWeb'),
                      isCurrentUserAuthor: _isCurrentUserAuthor,
                      setAudioWeb: setStoryAudioWeb,
                      width: width,
                    )
                  : RecorderWidget(
                      key: Key('storyPlayRecorderWidget'),
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
              _isWeb
                  ? RecorderWidgetWeb(
                      key: Key('storyPlayRecorderWidgetWeb'),
                      isCurrentUserAuthor: _isCurrentUserAuthor,
                      setAudioWeb: setStoryAudioWeb,
                      width: width,
                      url: host(_story['audio']))
                  : RecorderWidget(
                      key: Key('storyPlayRecorderWidget'),
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
          borderRadius: BorderRadius.circular(40.0),
          child: Image.memory(
            _image.buffer
                .asUint8List(_image.offsetInBytes, _image.lengthInBytes),
            width: _width.toDouble(),
            height: _height.toDouble(),
          ),
        ),
      );
    else if (_webImageBytes != null)
      return ClipRRect(
        borderRadius: BorderRadius.circular(40.0),
        child: Image.memory(
          _webImageBytes.buffer.asUint8List(
              _webImageBytes.offsetInBytes, _webImageBytes.lengthInBytes),
          width: _width.toDouble(),
          height: _height.toDouble(),
        ),
      );
    else if (_story != null)
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40.0),
          child: FadeInImage.memoryNetwork(
            width: _width.toDouble(),
            height: _height.toDouble(),
            placeholder: kTransparentImage,
            image: host(
              _story['image'],
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
                key: Key('deleteStory'),
                title: Strings.deleteStoryQuestion.i18n,
                content: Strings.areYouSure.i18n,
                cancelActionText: Strings.cancel.i18n,
                defaultActionText: Strings.yes.i18n,
              ).show(context);
              if (_deleteStory == true) {
                final GraphQLClient graphQLClient =
                    GraphQLProvider.of(context).value;

                final String id = _story['id'];
                await deleteStory(
                  graphQLClient,
                  id,
                );

                if (widget.params.isNotEmpty &&
                    widget.params.containsKey('onDelete')) {
                  widget.params['onDelete']();
                }
                Navigator.of(context).pop();
              }
            },
          ),
          _story['user']['isBook']
              ? SizedBox(
                  width: 10,
                )
              : Container(),
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
      SizedBox(height: _spacer.toDouble()),
      _story == null
          ? Container()
          : _isCurrentUserAuthor
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 5),
                    CustomRaisedButton(
                      key: Key('storyPlayAttentionButton'),
                      text: Strings.storyPlayAttention.i18n,
                      icon: Icon(
                        Icons.group_add,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.push<dynamic>(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) => TagFriendsPage(
                              key: Key('tagFriendsFromStoryPlay'),
                              story: _story,
                              onSaved: () {
                                setState(() {});
                              },
                            ),
                            fullscreenDialog: true,
                          ),
                        );
                      },
                    )
                  ],
                )
              : _story['tags'].length > 0
                  ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(
                        Icons.group_add,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      InkWell(
                        child: Text(Strings.storyPlayAttention.i18n),
                        onTap: () {
                          setState(() {
                            _showTaggedFriends = !_showTaggedFriends;
                          });
                        },
                      ),
                    ])
                  : Container(),
      _isCurrentUserAuthor
          ? const SizedBox(
              height: 10,
            )
          : Container(),
      _isCurrentUserAuthor && _story != null ||
              //story is book and book author is current user so they
              //can manage which stories they want on the book
              _story != null &&
                  _story['user']['isBook'] == true &&
                  _story['user']['bookAuthor']['id'] ==
                      graphQLAuth.getUserMap()['id']
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 5),
                CustomRaisedButton(
                  key: Key('storyPlayBookButton'),
                  text: Strings.storyPlayBookQuestion.i18n,
                  icon: Icon(
                    Icons.collections_bookmark,
                    size: 20,
                  ),
                  onPressed: () async {
                    Navigator.push<dynamic>(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (BuildContext context) => TagFriendsPage(
                            key: Key('selectBookFromStoryPlay'),
                            story: _story,
                            onSaved: () {
                              setState(() {});
                            },
                            isBook: true,
                            onBookSave: setBook),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                )
              ],
            )
          : Container(),
      _showTaggedFriends
          ? TaggedFriends(
              key: Key('tagStoryPlay'),
              items: _story['tags'],
            )
          : Container(),
    ]);
  }

  Widget getStoryTypeDropDown() {
    return Container(
      width: 300,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _isCurrentUserAuthor
              ? RadioGroup(
                  storyType: _storyType,
                  onSelect: (StoryType storyType) async {
                    setState(() {
                      _storyType = storyType;
                    });
                    await doStoryUpload();
                    setState(() {});
                  },
                )
              : Text(storyTypes[_storyType.index]),
        ],
      ),
    );
  }

  Widget getCard(BuildContext context) {
    return SingleChildScrollView(
      key: Key('storyPlayScrollView'),
      child: Container(
        padding: const EdgeInsets.only(
            left: 10.0, top: 0.0, right: 10.0, bottom: 10.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (_story != null ||
                  (widget.params != null &&
                      widget.params.containsKey('id') &&
                      widget.params['id'].isNotEmpty))
                FriendWidget(
                  user: _story['user'],
                  story: _story,
                  showMessage: false,
                ),
              if ((_story != null ||
                      (widget.params != null &&
                          widget.params.containsKey('id') &&
                          widget.params['id'].isNotEmpty)) &&
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
                                  _isWeb
                                      ? RecorderWidgetWeb(
                                          key:
                                              Key('storyPlayRecorderWidgetWeb'),
                                          isCurrentUserAuthor:
                                              _isCurrentUserAuthor,
                                          setAudioWeb: setCommentAudioWeb,
                                          timerDuration: 90,
                                          isForComment: true,
                                        )
                                      : RecorderWidget(
                                          key: Key('storyPlayRecorderWidget'),
                                          isCurrentUserAuthor:
                                              _isCurrentUserAuthor,
                                          setAudioFile: setCommentAudioFile,
                                          timerDuration: 90,
                                          isForComment: true,
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
                                    isWeb: _isWeb,
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
      ),
    );
  }
}
