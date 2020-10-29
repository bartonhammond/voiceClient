import 'package:flutter/material.dart';

import 'package:MyFamilyVoice/app/sign_in/message_button.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/constants/transparent_image.dart';
import 'package:MyFamilyVoice/services/host.dart';

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
        shape: RoundedRectangleBorder(
            side: BorderSide(
          color: Colors.grey,
          width: 2.0,
        )),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(height: 10),
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
            ButtonBar(
              mainAxisSize: MainAxisSize.min,
              buttonHeight: 20,
              children: <Widget>[
                approveButton,
                rejectButton,
              ],
            )
          ],
        ),
      ),
    );
  }
}
