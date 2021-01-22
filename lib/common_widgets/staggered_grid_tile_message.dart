import 'package:MyFamilyVoice/common_widgets/friend_widget.dart';
import 'package:MyFamilyVoice/common_widgets/player_widget.dart';
import 'package:MyFamilyVoice/services/utilities.dart';
import 'package:flutter/material.dart';
import 'package:MyFamilyVoice/app/sign_in/message_button.dart';
import 'package:MyFamilyVoice/services/host.dart';

class StaggeredGridTileMessage extends StatelessWidget {
  const StaggeredGridTileMessage({
    Key key,
    @required this.title,
    @required this.message,
    @required this.approveButton,
    @required this.rejectButton,
    this.isAudio = false,
  }) : super(key: key);

  final String title;
  final Map<String, dynamic> message;
  final MessageButton approveButton;
  final MessageButton rejectButton;
  final bool isAudio;

  @override
  Widget build(BuildContext context) {
    printJson('sgtm.build', message);
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
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
                key: Key('message-title'),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            ),
            FriendWidget(
              user: message['from'],
              showBorder: false,
              showMessage: message['type'] == 'message',
              message: message,
              showFamilyCheckbox: false,
              allowExpandToggle: false,
            ),
            isAudio
                ? Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      children: <Widget>[
                        PlayerWidget(
                          key: Key("playWidget${message['id']}"),
                          url: host(
                            message['key1'],
                          ),
                          //width: _width,
                        ),
                      ],
                    ),
                  )
                : Container(),
            ButtonBar(
              mainAxisSize: MainAxisSize.min,
              buttonHeight: 20,
              children: <Widget>[
                approveButton == null ? Container() : approveButton,
                rejectButton == null ? Container() : rejectButton,
              ],
            )
          ],
        ),
      ),
    );
  }
}
