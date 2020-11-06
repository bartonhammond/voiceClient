import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:MyFamilyVoice/constants/transparent_image.dart';
import 'package:MyFamilyVoice/services/host.dart';

class FriendWidget extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    DateTime dt;
    DateFormat df;
    if (story != null) {
      dt = DateTime.parse(story['updated']['formatted']);
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
      shape: showBorder
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
                if (onPush != null) {
                  onPush(<String, dynamic>{
                    'id': story['id'],
                    'onFinish': callBack,
                    'onDelete': onDelete,
                  });
                }
                if (onFriendPush != null) {
                  onFriendPush(<String, dynamic>{
                    'id': user['id'],
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
                    user['image'],
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
            user['name'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: _fontSize),
          ),
          Text(
            user['home'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: _fontSize),
          ),
          story == null
              ? Container()
              : Text(
                  df.format(dt),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
                ),
          user['id'] == graphQLAuth.getUserMap()['id']
              ? Container()
              : showMessage
                  ? Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      height: 1,
                      color: Colors.grey[300],
                    )
                  : Container(),
          user['id'] == graphQLAuth.getUserMap()['id']
              ? Container()
              : showMessage
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.comment,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        InkWell(child: Text('Message'), onTap: () {})
                      ],
                    )
                  : Container(),
          SizedBox(
            height: 7.toDouble(),
          ),
          friendButton == null ? Container() : friendButton,
          SizedBox(
            height: 7.toDouble(),
          ),
        ],
      ),
    );
  }
}
