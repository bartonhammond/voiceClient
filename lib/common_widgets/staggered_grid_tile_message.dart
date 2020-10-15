import 'package:flutter/material.dart';

import 'package:voiceClient/app/sign_in/message_button.dart';
import 'package:voiceClient/constants/mfv.i18n.dart';
import 'package:voiceClient/constants/strings.dart';
import 'package:voiceClient/constants/transparent_image.dart';
import 'package:voiceClient/services/host.dart';

class StaggeredGridTileMessage extends StatelessWidget {
  const StaggeredGridTileMessage({
    Key key,
    @required this.title,
    @required this.message,
    @required this.approveButton,
    @required this.rejectButton,
  }) : super(key: key);

  final String title;
  final Map<String, dynamic> message;
  final MessageButton approveButton;
  final MessageButton rejectButton;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Center(
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () {},
                child: message['User']['image'] == null
                    ? Image(
                        image: AssetImage('assets/placeholder.png'),
                        width: 100,
                        height: 100,
                      )
                    : FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: host(message['User']['image']),
                        height: 50,
                      ),
              ),
            ),
            Text(
              message['User']['name'] == null
                  ? Strings.yourFullNameLabel.i18n
                  : message['User']['name'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
              ),
            ),
            Text(
              message['User']['home'] == null
                  ? Strings.yourHomeLabel.i18n
                  : message['User']['home'],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
            ),
            ButtonBar(mainAxisSize: MainAxisSize.min, children: <Widget>[
              approveButton,
              rejectButton,
            ])
          ],
        ),
      ),
    );
  }
}
