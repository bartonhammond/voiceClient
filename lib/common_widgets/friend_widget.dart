import 'dart:io' as io;
import 'package:MyFamilyVoice/common_widgets/recorder_widget.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/mutation_service.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:MyFamilyVoice/constants/transparent_image.dart';
import 'package:MyFamilyVoice/services/host.dart';

class FriendWidget extends StatefulWidget {
  const FriendWidget({
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
  });
  final Map<String, dynamic> user;
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

  @override
  State<StatefulWidget> createState() => _FriendWidgetState();
}

class _FriendWidgetState extends State<FriendWidget> {
  bool _showMakeMessage = false;
  bool _uploadInProgress = false;
  io.File _messageAudio;

  Future<void> setCommentAudioFile(io.File audio) async {
    if (audio == null) {
      return;
    }
    setState(() {
      _messageAudio = audio;
      _uploadInProgress = true;
    });
    await doMessageUploads(
      context,
      widget.user['id'],
      _messageAudio,
    );
    setState(() {
      _showMakeMessage = false;
      _messageAudio = null;
      _uploadInProgress = false;
    });

    return;
  }

  @override
  Widget build(BuildContext context) {
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
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    return Card(
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
          Center(
            child: GestureDetector(
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
          ),
          Text(
            widget.user['name'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: _fontSize),
          ),
          Text(
            widget.user['home'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: _fontSize),
          ),
          widget.story == null
              ? Container()
              : Text(
                  df.format(dt),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
                ),
          widget.showFamilyCheckbox
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                        value: true, //widget.user['family'],
                        onChanged: (bool newValue) {
                          setState(() {
                            //toggle update
                          });
                        }),
                    Text('Family'),
                  ],
                )
              : Container(),
          widget.message == null
              ? Container()
              : Text(
                  df.format(dt),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
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
                            child: Text('Message'),
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
          _showMakeMessage
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                        height: 1,
                        color: Colors.grey[300],
                      ),
                      Text('Record Message',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(
                        height: 20,
                      ),
                      RecorderWidget(
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
