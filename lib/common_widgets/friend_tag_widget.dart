import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:MyFamilyVoice/constants/transparent_image.dart';
import 'package:MyFamilyVoice/services/host.dart';

// ignore: must_be_immutable
class FriendTagWidget extends StatefulWidget {
  FriendTagWidget({
    @required this.user,
    @required this.typeUser,
    this.onSelect,
  });
  Map<String, dynamic> user;
  TypeUser typeUser;
  void Function(Map<String, dynamic>) onSelect;

  @override
  State<StatefulWidget> createState() => _FriendTagWidgetState();
}

class _FriendTagWidgetState extends State<FriendTagWidget> {
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
      shadowColor: Colors.transparent,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          leading: GestureDetector(
            onTap: () {

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
          title: AutoSizeText(
            widget.user['name'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _fontSize,
            ),
          ),
          subtitle: AutoSizeText(
            widget.user['home'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _fontSize,
            ),
          ),
          trailing: Checkbox(
            value: false,
            onChanged: (bool newValue) {
              if (widget.onSelect != null) {
                widget.onSelect(widget.user);
              }
            },
          ),
        )
      ]),
    );
  }
}
