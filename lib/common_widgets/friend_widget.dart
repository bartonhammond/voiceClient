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
import 'package:MyFamilyVoice/services/utilities.dart';
import 'package:flutter/material.dart';
import 'package:MyFamilyVoice/services/logger.dart' as logger;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:MyFamilyVoice/constants/transparent_image.dart';
import 'package:MyFamilyVoice/services/host.dart';
import 'package:MyFamilyVoice/constants/globals.dart' as globals;
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';

// ignore: must_be_immutable
class FriendWidget extends StatefulWidget {
  FriendWidget(
      {@required this.user,
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
      this.onBanned});
  Map<String, dynamic> user;
  final ValueChanged<Map<String, dynamic>> onPush;
  Map<String, dynamic> story;
  final VoidCallback onDelete;
  final VoidCallback callBack;
  final VoidCallback onBanned;
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
  Map bookAuthorUser;
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
        graphQLAuth.getUserMap()['email'],
      );
      //printJson('friendWidget.callBack', user);
      setState(() {
        widget.user = user;
      });
    } catch (e) {
      print(e);
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

  Future<Map> getBookAuthor() async {
    if (widget.story != null) {
      return null;
    }

    if (widget.user != null && !widget.user['isBook']) {
      return null;
    }
    return await getUserByEmail(
      graphQLClient,
      widget.user['bookAuthorEmail'],
      graphQLAuth.getUserMap()['email'],
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
        _width = _height = 100;
        break;
      case DeviceScreenType.watch:
        _width = _height = 50;
        break;
      case DeviceScreenType.mobile:
        _width = _height = 100;
        break;
      default:
        _width = _height = 100;
    }

    return FutureBuilder(
      future: Future.wait([
        getBookAuthor(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          logger.createMessage(
              userEmail: graphQLAuth.getUser().email,
              source: 'friend_widget',
              shortMessage: snapshot.error.toString(),
              stackTrace: StackTrace.current.toString());
          return Text('\nErrors: \n  ' + snapshot.error.toString());
        } else if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        bookAuthorUser = snapshot.data[0];

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
                  ])
            : getCard(
                _width,
                _height,
                _fontSize,
                dt,
                df,
              );
      },
    );
  }

  Widget getCard(
    int _width,
    int _height,
    double _fontSize,
    DateTime dt,
    DateFormat df,
  ) {
    return GestureDetector(
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
            'email': widget.user['email'],
          });
        }
      },
      child: Card(
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
              mainAxisAlignment: MainAxisAlignment.center,
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
                ClipRRect(
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
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.65,
              child: Text(
                widget.user['name'],
                key: Key('userName-${widget.user["name"]}'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: _fontSize,
                ),
                maxLines: 10,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.65,
              child: Text(
                widget.user['home'],
                key: Key('userHome-${widget.user["name"]}'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: _fontSize,
                ),
                maxLines: 10,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
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
            widget.story != null && widget.user['isBook']
                ? getStoryBookColumn(_fontSize)
                : Container(),
            widget.story == null ? getUserBookColumn(_fontSize) : Container(),
            widget.showFamilyCheckbox
                ? widget.user['email'] == graphQLAuth.getUserMap()['email'] ||
                        (widget.story != null &&
                            widget.story['originalUser'] != null &&
                            widget.story['originalUser'].containsKey('email') &&
                            widget.story['originalUser']['email'] ==
                                graphQLAuth.getUserMap()['email'])
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
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
                  ),
            widget.user['id'] == graphQLAuth.getUserMap()['id'] ||
                    (widget.story != null &&
                        widget.story.containsKey('originalUser') &&
                        widget.story['originalUser'] != null &&
                        widget.story['originalUser'].containsKey('email') &&
                        widget.story['originalUser']['email'] ==
                            graphQLAuth.getUserMap()['email'])
                ? Container()
                : widget.showMessage
                    ? Container(
                        margin: EdgeInsets.fromLTRB(25, 10, 25, 20),
                        height: 1,
                        color: Colors.grey[300],
                      )
                    : Container(),
            widget.user['id'] == graphQLAuth.getUserMap()['id'] ||
                    (widget.story != null &&
                        widget.story.containsKey('originalUser') &&
                        widget.story['originalUser'] != null &&
                        widget.story['originalUser'].containsKey('email') &&
                        widget.story['originalUser']['email'] ==
                            graphQLAuth.getUserMap()['email'])
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
            widget.friendButton == null
                ? Container()
                : widget.user['bookAuthorEmail'] ==
                        graphQLAuth.getUserMap()['email']
                    ? Container()
                    : widget.friendButton,
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
      ),
    );
  }

  Future<void> _confirmBan(
    BuildContext context,
    bool banned,
    String userNameBanned,
    String userIdBanned,
  ) async {
    if (!banned) {
      final bool ban = await PlatformAlertDialog(
        key: Key('banConfirmation'),
        title: Strings.banUser.i18n + " '$userNameBanned'",
        content: Strings.areYouSureYouWantToBan.i18n,
        cancelActionText: Strings.cancel.i18n,
        defaultActionText: Strings.yes.i18n,
      ).show(context);
      if (ban == true) {
        await addUserBanned(
          graphQLClient,
          graphQLAuth.getUserMap()['id'],
          userIdBanned,
        );
        setState(() {});
        if (widget.onBanned != null) {
          widget.onBanned();
        }
        if (widget.story == null) {
          callBack();
        }
      }
    } else {
      final bool banRemove = await PlatformAlertDialog(
        key: Key('banConfirmation'),
        title: Strings.unbanUser + " '$userNameBanned'",
        content: Strings.removeTheBan,
        cancelActionText: Strings.cancel.i18n,
        defaultActionText: Strings.yes.i18n,
      ).show(context);
      if (banRemove == true) {
        await removeUserBanned(
          graphQLClient,
          graphQLAuth.getUserMap()['id'],
          userIdBanned,
        );
        if (widget.story == null) {
          callBack();
        } else {
          setState(() {});
        }
      }
    }
  }

  Widget getStoryBookColumn(double _fontSize) {
    bool banned = false;
    bool showBannedBox = false;
    String userNameBanned = 'None';
    String userIdBanned = 'None';

    if (widget.story != null) {
      //printJson('friendWidget.getStoryBookColumn', widget.story);

      //is current person the originalUser
      if (widget.story.containsKey('originalUser') &&
          widget.story['originalUser'] != null &&
          widget.story['originalUser'].containsKey('email') &&
          widget.story['originalUser']['email'] ==
              graphQLAuth.getUserMap()['email']) {
        return Container();
      }

      //already friends w/ the originalUser, then don't ban
      if (widget.story.containsKey('originalUser') &&
          widget.story['originalUser'] != null &&
          widget.story['originalUser'].containsKey('friends') &&
          widget.story['originalUser']['friends'].containsKey('to') &&
          widget.story['originalUser']['friends'].length == 1) {
        return Container();
      }

      userNameBanned = widget.story['originalUser']['name'];
      userIdBanned = widget.story['originalUser']['id'];
      showBannedBox = true;
      banned = false;
    }

    return getOriginalUserDetail(
        _fontSize, showBannedBox, banned, userNameBanned, userIdBanned);
  }

  Widget getOriginalUserDetail(
    double _fontSize,
    bool showBannedBox,
    bool banned,
    String userNameBanned,
    String userIdBanned,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(Strings.writtenByTitle.i18n,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: _fontSize,
              )),
          Text(
            userNameBanned,
            key: Key('originalUser-$userNameBanned'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _fontSize,
            ),
          ),
          showBannedBox
              ? getBanRow(banned, userNameBanned, userIdBanned)
              : Container()
        ],
      ),
    );
  }

  Widget getBanRow(bool banned, String userNameBanned, String userIdBanned) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Ban?'),
        SizedBox(
          height: 24.0,
          width: 24.0,
          child: Checkbox(
            key: Key('originalUserBan-$userNameBanned'),
            value: banned,
            onChanged: (bool bannedValue) {
              _confirmBan(context, !bannedValue, userNameBanned, userIdBanned);
            },
          ),
        ),
      ],
    );
  }

  Widget getUserBookColumn(double _fontSize) {
    //When reading messages there are neither story or user
    if (widget.user == null ||
        !widget.user['isBook'] ||
        !widget.user.containsKey('banned')) {
      return Container();
    }
    //Is current author the original
    if (widget.user['bookAuthorEmail'] == graphQLAuth.getUserMap()['email']) {
      return Container();
    }
    /*printJson(
      'friendWidget.getUserBookColumn widget.user',
      widget.user,
    );*/
    bool showBannedBox = false;
    bool banned = false;
    String userNameBanned = 'None';
    String userIdBanned = 'None';
    /*
    printJson(
      'friendWidget.getUserBookColumn bookAuthorUser',
      bookAuthorUser,
    );*/

    if (widget.user['banned']['from'].length == 1) {
      userNameBanned = widget.user['name'];
      userIdBanned = widget.user['id'];
      banned = true;
      showBannedBox = true;
    } else {
      //If this were a Book, then the build would
      //have got the bookAuthorUser
      userNameBanned = bookAuthorUser['name'];
      userIdBanned = bookAuthorUser['id'];
      if (bookAuthorUser['banned']['from'].length == 1) {
        banned = true;
      }
      showBannedBox = true;
    }

    return getOriginalUserDetail(
        _fontSize, showBannedBox, banned, userNameBanned, userIdBanned);
  }
}
