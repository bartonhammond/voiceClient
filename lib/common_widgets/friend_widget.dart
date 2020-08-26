import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:voiceClient/constants/transparent_image.dart';
import 'package:voiceClient/services/host.dart';

Widget buildFriend(BuildContext context, Map<String, dynamic> user) {
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
    child: Column(
      children: <Widget>[
        //new Center(child: new CircularProgressIndicator()),
        Center(
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
        Text(
          user['name'],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
        Text(
          user['home'],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
        Text(
          user['birth'].toString(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
        )
      ],
    ),
  );
}
