import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'package:voiceClient/constants/transparent_image.dart';
import 'package:voiceClient/services/host.dart';

class StaggeredGridTileFriend extends StatelessWidget {
  const StaggeredGridTileFriend({
    @required this.onPush,
    @required this.friend,
    @required this.friendButton,
  });
  final ValueChanged<Map<String, dynamic>> onPush;
  final Map friend;
  final Widget friendButton;

  @override
  Widget build(BuildContext context) {
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

    return Card(
      shadowColor: Colors.white,
      child: GestureDetector(
        onTap: () {
          if (onPush != null) {
            onPush(<String, dynamic>{
              'id': friend['id'],
            });
          }
        },
        child: Column(
          children: <Widget>[
            Center(
              child: InkWell(
                onTap: () {
                  if (onPush != null) {
                    onPush(<String, dynamic>{
                      'id': friend['id'],
                    });
                  }
                },
                child: friend['image'] == null
                    ? Image(
                        image: AssetImage('assets/placeholder.png'),
                        width: 100,
                        height: 100,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(25.0),
                        child: FadeInImage.memoryNetwork(
                          height: _height.toDouble(),
                          width: _width.toDouble(),
                          placeholder: kTransparentImage,
                          image: host(
                            friend['image'],
                            width: _width,
                            height: _height,
                            resizingType: 'fill',
                            enlarge: 1,
                          ),
                        ),
                      ),
              ),
            ),
            friend['name'] == null
                ? Text(
                    'Name...',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: _fontSize),
                  )
                : Text(
                    friend['name'],
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: _fontSize),
                  ),
            friend['home'] == null
                ? Text(
                    'Home...',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: _fontSize),
                  )
                : Text(
                    friend['home'],
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: _fontSize),
                  ),
            friend['birth'] == null
                ? Text(
                    'Birth...',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: _fontSize),
                  )
                : Text(
                    friend['birth'].toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: _fontSize),
                  ),
            friendButton
          ],
        ),
      ),
    );
  }
}
