import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:MyFamilyVoice/app/sign_in/message_button.dart';
import 'package:MyFamilyVoice/app_config.dart';
import 'package:MyFamilyVoice/common_widgets/platform_alert_dialog.dart';
import 'package:MyFamilyVoice/common_widgets/recorder_widget.dart';
import 'package:MyFamilyVoice/common_widgets/recorder_widget_web.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/services/eventBus.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/mutation_service.dart';
import 'package:MyFamilyVoice/services/queries_service.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:MyFamilyVoice/constants/transparent_image.dart';
import 'package:MyFamilyVoice/services/host.dart';
import 'package:MyFamilyVoice/constants/globals.dart' as globals;
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';

// ignore: must_be_immutable
class FriendWidget extends StatefulWidget {
  FriendWidget({
    @required this.user,
    this.onPush,
    this.story,
    this.onDelete,
    this.callBack,
    this.friendButton,
    this.onFriendPush,
    this.showBorder = true,
    this.showMessage = true,
    this.message,
    this.showFamilyCheckbox = true,
    this.allowExpandToggle = true,
  });
  Map<String, dynamic> user;
  final ValueChanged<Map<String, dynamic>> onPush;
  final Map<String, dynamic> story;
  final VoidCallback onDelete;
  final VoidCallback callBack;
  final Widget friendButton;
  final ValueChanged<Map<String, dynamic>> onFriendPush;
  final bool showBorder;
  final bool showMessage;
  final bool showFamilyCheckbox;
  final Map<String, dynamic> message;
  final bool allowExpandToggle;

  @override
  State<StatefulWidget> createState() => _FriendWidgetState();
}

class _FriendWidgetState extends State<FriendWidget> {
  bool _showMakeMessage = false;
  bool _uploadInProgress = false;
  bool _isWeb = false;
  Uint8List _messageAudioWeb;
  io.File _messageAudio;
  bool _showDeleteButton = false;
  final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
  GraphQLClient graphQLClient;
  GraphQLClient graphQLClientFileServer;
  StreamSubscription bookHasNoStories;
  @override
  void initState() {
    super.initState();
    bookHasNoStories = eventBus.on<BookHasNoStories>().listen((event) {
      if (event.id == widget.user['id']) {
        setState(() {
          _showDeleteButton = true;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    bookHasNoStories.cancel();
  }

  Future<void> setStoryAudioWeb(Uint8List bytes) async {
    if (bytes == null) {
      return;
    }
    setState(() {
      _messageAudioWeb = bytes;
      _uploadInProgress = true;
    });

    await doMessageUploads(
      graphQLAuth,
      graphQLClientFileServer,
      graphQLClient,
      widget.user,
      messageAudioWeb: _messageAudioWeb,
    );

    setState(() {
      _showMakeMessage = false;
      _messageAudioWeb = null;
      _uploadInProgress = false;
    });
  }

  Future<void> setCommentAudioFile(io.File audio) async {
    if (audio == null) {
      return;
    }
    setState(() {
      _messageAudio = audio;
      _uploadInProgress = true;
    });

    await doMessageUploads(
      graphQLAuth,
      graphQLClientFileServer,
      graphQLClient,
      widget.user,
      messageAudio: _messageAudio,
    );
    setState(() {
      _showMakeMessage = false;
      _messageAudio = null;
      _uploadInProgress = false;
    });

    return;
  }

  Future<void> callBack() async {
    try {
      final user = await getUserByEmail(
        graphQLClient,
        widget.user['email'],
      );

      setState(() {
        widget.user = user;
      });
    } catch (e) {
      //ignore
    }
  }

  bool checkIfIsFamily() {
    if (widget.user.containsKey('friends') &&
        widget.user['friends'].containsKey('from') &&
        widget.user['friends']['from'].length > 0) {
      for (var i = 0; i < widget.user['friends']['from'].length; i++) {
        if (widget.user['friends']['from'][i].containsKey('isFamily')) {
          if (widget.user['friends']['from'][i]['isFamily']) {
            if (widget.user['friends']['from'][i].containsKey('User')) {
              if (widget.user['friends']['from'][i]['User']
                      .containsKey('email') &&
                  widget.user['friends']['from'][i]['User']['email'] ==
                      graphQLAuth.getUserMap()['email']) {
                return true;
              }
            }
          }
        }
      }
    }

    return false;
  }

  Widget getDeleteButton() {
    final DeviceScreenType deviceType =
        getDeviceType(MediaQuery.of(context).size);
    double _fontSize = 20;
    switch (deviceType) {
      case DeviceScreenType.watch:
        _fontSize = 12;
        break;
      default:
        _fontSize = 20;
    }

    return MessageButton(
      key: Key('messageButton-${widget.user["id"]}'),
      text: Strings.deleteBookButton,
      onPressed: () async {
        final bool delete = await PlatformAlertDialog(
          title: Strings.deleteBookTitle.i18n,
          content: Strings.areYouSure.i18n,
          cancelActionText: Strings.cancel.i18n,
          defaultActionText: Strings.yes.i18n,
        ).show(context);
        if (delete) {
          await deleteBook(graphQLClient, widget.user['email']);
          //fire event so FriendsPage can setState
          eventBus.fire(BookWasDeleted());
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      },
      fontSize: _fontSize,
      icon: Icon(
        Icons.collections_bookmark,
        color: Colors.white,
      ),
    );
  }

  Widget getProxyButton() {
    final DeviceScreenType deviceType =
        getDeviceType(MediaQuery.of(context).size);
    double _fontSize = 20;
    switch (deviceType) {
      case DeviceScreenType.watch:
        _fontSize = 12;
        break;
      default:
        _fontSize = 20;
    }

    return MessageButton(
      key: Key('manageButton-${widget.user["name"]}'),
      text: Strings.manageBook.i18n,
      onPressed: () async {
        await graphQLAuth.setProxy(widget.user['email']);
        setState(() {});
        eventBus.fire(ProxyStarted());
        //Check if there are pending messages
        eventBus.fire(GetUserMessagesEvent());
      },
      fontSize: _fontSize,
      icon: Icon(
        Icons.collections_bookmark,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _isWeb = AppConfig.of(context).isWeb;
    graphQLClient = GraphQLProvider.of(context).value;
    graphQLClientFileServer =
        graphQLAuth.getGraphQLClient(GraphQLClientType.FileServer);
    DateTime dt;
    DateFormat df;
    if (widget.story != null) {
      dt = DateTime.parse(widget.story['updated']['formatted']);
      df = DateFormat.yMd().add_jm();
    }

    if (widget.message != null) {
      dt = DateTime.parse(widget.message['created']['formatted']);
      df = DateFormat.yMd().add_jm();
    }

    final DeviceScreenType deviceType =
        getDeviceType(MediaQuery.of(context).size);
    double _fontSize = 16;
    switch (deviceType) {
      case DeviceScreenType.watch:
        _fontSize = 10;
        break;
      default:
        _fontSize = 16;
    }
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
    return widget.allowExpandToggle && globals.collapseFriendWidget
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
                GestureDetector(
                    onTap: () {
                      setState(() {
                        globals.collapseFriendWidget =
                            !globals.collapseFriendWidget;
                      });
                    },
                    child: Icon(
                      Icons.expand_more,
                      color: Color(0xff00bcd4),
                      size: 20,
                    )),
                Text(
                  widget.user['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: _fontSize,
                  ),
                ),
                Container(),
              ])
        : Card(
            shadowColor: Colors.transparent,
            borderOnForeground: false,
            shape: widget.showBorder
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: BorderSide(
                      color: Colors.grey,
                      width: 2.0,
                    ))
                : null,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 7.toDouble(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    widget.allowExpandToggle
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                globals.collapseFriendWidget =
                                    !globals.collapseFriendWidget;
                              });
                            },
                            child: Icon(
                              Icons.expand_less,
                              color: Color(0xff00bcd4),
                              size: 20,
                            ),
                          )
                        : Container(),
                    GestureDetector(
                      onTap: () {
                        if (widget.onPush != null) {
                          widget.onPush(<String, dynamic>{
                            'id': widget.story['id'],
                            'onFinish': widget.callBack,
                            'onDelete': widget.onDelete,
                          });
                        }
                        if (widget.onFriendPush != null) {
                          widget.onFriendPush(<String, dynamic>{
                            'id': widget.user['id'],
                          });
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25.0),
                        child: FadeInImage.memoryNetwork(
                          height: _height.toDouble(),
                          width: _width.toDouble(),
                          placeholder: kTransparentImage,
                          image: host(
                            widget.user['image'],
                            width: _width,
                            height: _height,
                            resizingType: 'fill',
                            enlarge: 1,
                          ),
                        ),
                      ),
                    ),
                    Container(),
                  ],
                ),
                Text(
                  widget.user['name'],
                  key: Key('userName-${widget.user["name"]}'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: _fontSize,
                  ),
                ),
                Text(
                  widget.user['home'],
                  key: Key('userHome-${widget.user["name"]}'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: _fontSize,
                  ),
                ),
                widget.story == null
                    ? Container()
                    : Text(
                        df.format(dt),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10.0,
                        ),
                      ),
                widget.user['isBook']
                    ? Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: Text('Book'))
                    : Container(),
                widget.showFamilyCheckbox
                    ? widget.user['email'] == graphQLAuth.getUserMap()['email']
                        ? Container()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Checkbox(
                                  value: checkIfIsFamily(),
                                  onChanged: (bool newValue) async {
                                    await updateUserIsFamily(
                                      graphQLClient,
                                      graphQLAuth.getUserMap()['email'],
                                      widget.user['email'],
                                      newValue,
                                    );
                                    callBack();
                                  }),
                              Text(Strings.storiesPageFamily.i18n),
                            ],
                          )
                    : checkIfIsFamily()
                        ? Text(Strings.storiesPageFamily.i18n)
                        : Container(),
                widget.message == null
                    ? Container()
                    : Text(
                        df.format(dt),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 10.0),
                      ),
                widget.user['id'] == graphQLAuth.getUserMap()['id']
                    ? Container()
                    : widget.showMessage
                        ? Container(
                            margin: EdgeInsets.fromLTRB(25, 10, 25, 20),
                            height: 1,
                            color: Colors.grey[300],
                          )
                        : Container(),
                widget.user['id'] == graphQLAuth.getUserMap()['id']
                    ? Container()
                    : widget.showMessage
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.message,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                  child: Text(Strings.friendWidgetMessage.i18n),
                                  onTap: () {
                                    setState(() {
                                      _showMakeMessage = !_showMakeMessage;
                                    });
                                  })
                            ],
                          )
                        : Container(),
                widget.friendButton == null
                    ? Container()
                    : SizedBox(
                        height: 10.toDouble(),
                      ),
                widget.friendButton == null ? Container() : widget.friendButton,
                SizedBox(
                  height: 7.toDouble(),
                ),
                widget.user['isBook'] &&
                        widget.user['bookAuthorEmail'] ==
                            graphQLAuth.getUserMap()['email']
                    ? graphQLAuth.isProxy
                        ? Container()
                        : getProxyButton()
                    : Container(),
                widget.user['isBook'] &&
                        widget.user['bookAuthorEmail'] ==
                            graphQLAuth.getUserMap()['email']
                    ? SizedBox(
                        height: 7.toDouble(),
                      )
                    : Container(),
                widget.user['isBook'] &&
                        _showDeleteButton &&
                        widget.user['bookAuthorEmail'] ==
                            graphQLAuth.getUserMap()['email']
                    ? graphQLAuth.isProxy
                        ? Container()
                        : getDeleteButton()
                    : Container(),
                widget.user['isBook'] &&
                        _showDeleteButton &&
                        widget.user['bookAuthorEmail'] ==
                            graphQLAuth.getUserMap()['email']
                    ? SizedBox(
                        height: 7.toDouble(),
                      )
                    : Container(),
                _showMakeMessage
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 15),
                              height: 1,
                              color: Colors.grey[300],
                            ),
                            Text(Strings.friendWidgetRecordMessage.i18n,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(
                              height: 20,
                            ),
                            _isWeb
                                ? RecorderWidgetWeb(
                                    key: Key('friendWidgetRecorderWeb'),
                                    showStacked: true,
                                    showIcon: true,
                                    isCurrentUserAuthor: true,
                                    setAudioWeb: setStoryAudioWeb,
                                    timerDuration: 90,
                                    showPlayerWidget: false,
                                  )
                                : RecorderWidget(
                                    key: Key('friendWidgetRecorder'),
                                    showStacked: true,
                                    showIcon: true,
                                    isCurrentUserAuthor: true,
                                    setAudioFile: setCommentAudioFile,
                                    timerDuration: 90,
                                    showPlayerWidget: false,
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
          );
  }
}
