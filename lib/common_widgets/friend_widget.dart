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
import 'package:MyFamilyVoice/ql/user/user_ban.dart';
import 'package:MyFamilyVoice/ql/user/user_book_author.dart';
import 'package:MyFamilyVoice/ql/user/user_friends.dart';
import 'package:MyFamilyVoice/ql/user/user_messages_received.dart';
import 'package:MyFamilyVoice/ql/user/user_search.dart';
import 'package:MyFamilyVoice/ql/user_ql.dart';
import 'package:MyFamilyVoice/services/eventBus.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/mutation_service.dart';
import 'package:MyFamilyVoice/services/queries_service.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:MyFamilyVoice/services/utilities.dart';
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
      final UserMessagesReceived userMessagesReceived =
          UserMessagesReceived(useFilter: true);
      final UserBookAuthor userBookAuthor = UserBookAuthor(useFilter: true);
      final UserBan userBan = UserBan();
      final UserFriends userFriends = UserFriends(useFilter: true);
      final UserQl userQL = UserQl(
        userMessagesReceived: userMessagesReceived,
        userFriends: userFriends,
        userBookAuthor: userBookAuthor,
        userBan: userBan,
      );

      final UserSearch userSearch = UserSearch.init(
        graphQLClient,
        userQL,
        graphQLAuth.getUserMap()['email'],
      );

      userSearch.setQueryName('getUserByEmail');
      userSearch.setVariables(<String, dynamic>{
        'currentUserEmail': 'String!',
      });

      final Map user = await userSearch.getItem(<String, dynamic>{
        'currentUserEmail': widget.user['email'],
      });

      setState(() {
        widget.user = user;
      });
    } catch (e) {
      print(e);
    }
  }

  bool checkIfIsFamily() {
    if (widget.user.containsKey('friendsFrom') &&
        widget.user['friendsFrom'].length > 0) {
      for (var friend in widget.user['friendsFrom']) {
        if (friend['sender']['email'] == graphQLAuth.getUserMap()['email']) {
          return friend['isFamily'];
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

    return widget.allowExpandToggle && globals.collapseFriendWidget
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
              Flexible(
                child: Container(
                  padding: EdgeInsets.only(right: 13.0),
                  child: Text(
                    widget.user['name'],
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: _fontSize,
                    ),
                  ),
                ),
              ),
            ],
          )
        : getCard(
            _width,
            _height,
            _fontSize,
            dt,
            df,
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
            widget.story != null && widget.story['user']['isBook']
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
                              key:
                                  Key('familyCheckbox-${widget.user["email"]}'),
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
                              key: Key('message-display'),
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
                : widget.user['email'] == graphQLAuth.getUserMap()['email']
                    ? Container()
                    : widget.friendButton,
            SizedBox(
              height: 7.toDouble(),
            ),
            widget.user['isBook'] &&
                    _showDeleteButton &&
                    widget.user['bookAuthor']['email'] ==
                        graphQLAuth.getUserMap()['email']
                ? getDeleteButton()
                : Container(),
            widget.user['isBook'] &&
                    _showDeleteButton &&
                    widget.user['bookAuthor']['email'] ==
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
    String banId,
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
        await addBanned(
          graphQLClient,
          graphQLAuth.getUserMap()['id'],
          userIdBanned,
        );
        if (widget.onBanned != null) {
          widget.onBanned();
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
        await deleteBanned(
          graphQLClient,
          banId,
        );
        if (widget.onBanned != null) {
          widget.onBanned();
        }
      }
    }
  }

  Widget getStoryBookColumn(double _fontSize) {
    bool banned = false;
    bool showBannedBox = true;
    String userNameBanned = 'None';
    String userIdBanned = 'None';

    if (widget.story != null) {
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
          widget.story['originalUser']['friends']['to'].length > 0) {
        for (Map aFriend in widget.story['originalUser']['friends']['to']) {
          if (aFriend['User']['email'] == graphQLAuth.getUserMap()['email']) {
            showBannedBox = false;
            break;
          }
        }
      }
      if (widget.story['originalUser'] != null) {
        userNameBanned = widget.story['originalUser']['name'];
        userIdBanned = widget.story['originalUser']['id'];
      }
      banned = false;

      return getOriginalUserDetail(
          fontSize: _fontSize,
          showBannedBox: showBannedBox,
          banned: banned,
          showUserDetail: true,
          userNameBanned: userNameBanned,
          userIdBanned: userIdBanned);
    }
    return Container();
  }

  Widget getOriginalUserDetail({
    double fontSize,
    bool showBannedBox,
    bool banned,
    bool showUserDetail,
    String userNameBanned,
    String userIdBanned,
    String banId,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          showUserDetail
              ? Text(Strings.writtenByTitle.i18n,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  ))
              : Container(),
          showUserDetail
              ? Text(
                  userNameBanned,
                  key: Key('originalUser-$userNameBanned'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  ),
                )
              : Container(),
          showBannedBox
              ? getBanRow(banned, userNameBanned, userIdBanned, banId)
              : Container()
        ],
      ),
    );
  }

  Widget getBanRow(
    bool banned,
    String userNameBanned,
    String userIdBanned,
    String banId,
  ) {
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
              _confirmBan(
                context,
                !bannedValue,
                userNameBanned,
                userIdBanned,
                banId,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget getUserBookColumn(double _fontSize) {
    //When reading messages there are neither story or user
    if (widget.user == null) {
      return Container();
    }
    if (widget.message != null) {
      return Container();
    }
    if (widget.user['email'] == graphQLAuth.getUserMap()['email']) {
      return Container();
    }

    //The bookAuthor can be banned if they are not friends
    bool isFriend = false;
    if (widget.user['isBook']) {
      final String userNameBanned = widget.user['bookAuthor']['name'];
      final String userIdBanned = widget.user['bookAuthor']['id'];

      if (widget.user['bookAuthor']['friendsTo'].length > 0) {
        for (Map aFriend in widget.user['bookAuthor']['friendsTo']) {
          if (aFriend['receiver']['email'] ==
              graphQLAuth.getUserMap()['email']) {
            isFriend = true;
            break;
          }
        }
      }
      if (isFriend) {
        //show the author info
        return getOriginalUserDetail(
          fontSize: _fontSize,
          showBannedBox: false,
          banned: false,
          showUserDetail: true,
          userNameBanned: userNameBanned,
          userIdBanned: userIdBanned,
        );
      }
      const bool showBannedBox = true;
      bool banned = false;
      const bool showUserDetail = true;
      String banId = '';

      if (widget.user['bookAuthor'] != null &&
          widget.user['bookAuthor']['banned'] != null &&
          widget.user['bookAuthor']['banned'].length > 0) {
        for (Map userBan in widget.user['bookAuthor']['banned']) {
          if (userBan['banner']['email'] == graphQLAuth.getUserMap()['email']) {
            banId = userBan['id'];
            banned = true;
            break;
          }
        }
      }
      return getOriginalUserDetail(
          fontSize: _fontSize,
          showBannedBox: showBannedBox,
          banned: banned,
          showUserDetail: showUserDetail,
          userNameBanned: userNameBanned,
          userIdBanned: userIdBanned,
          banId: banId);
    } //isBook

    //Are you friends?  Don't ban if friends
    if (widget.user['friends'] != null &&
        widget.user['friends']['to'] != null &&
        widget.user['friends']['to'].length > 0) {
      for (Map aFriend in widget.user['friends']['to']) {
        if (aFriend['User']['email'] == graphQLAuth.getUserMap()['email']) {
          return Container();
        }
      }
    }

    const bool showBannedBox = true;
    bool banned = false;
    String banId = '';
    const bool showUserDetail = false;
    final String userNameBanned = widget.user['name'];
    final String userIdBanned = widget.user['id'];

    if (widget.user['banned'] != null && widget.user['banned'].length > 0) {
      for (Map aUser in widget.user['banned']) {
        if (aUser['banner']['email'] == graphQLAuth.getUserMap()['email']) {
          banned = true;
          banId = aUser['id'];
          break;
        }
      }
    }
    return getOriginalUserDetail(
        fontSize: _fontSize,
        showBannedBox: showBannedBox,
        banned: banned,
        showUserDetail: showUserDetail,
        userNameBanned: userNameBanned,
        userIdBanned: userIdBanned,
        banId: banId);
  }
}
