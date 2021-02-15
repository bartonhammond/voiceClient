import 'package:MyFamilyVoice/common_widgets/friend_widget.dart';
import 'package:MyFamilyVoice/common_widgets/player_widget.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:MyFamilyVoice/common_widgets/message_button.dart';
import 'package:MyFamilyVoice/services/host.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';

class StaggeredGridTileMessage extends StatefulWidget {
  const StaggeredGridTileMessage({
    Key key,
    @required this.title,
    @required this.message,
    @required this.approveButton,
    @required this.rejectButton,
    this.isAudio = false,
    this.onFamilyCheckboxClicked,
  }) : super(key: key);

  final String title;
  final Map<String, dynamic> message;
  final MessageButton approveButton;
  final MessageButton rejectButton;
  final bool isAudio;
  final void Function(bool) onFamilyCheckboxClicked;

  @override
  _StaggeredGridTileMessageState createState() =>
      _StaggeredGridTileMessageState();
}

class _StaggeredGridTileMessageState extends State<StaggeredGridTileMessage> {
  bool familyCheckboxValue = false;
  @override
  Widget build(BuildContext context) {
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
                widget.title,
                key: Key('message-title'),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            ),
            widget.message['book'] == null
                ? Container()
                : FriendWidget(
                    user: widget.message['book'],
                    showBorder: false,
                    showMessage: false,
                    message: widget.message,
                    showFamilyCheckbox: false,
                    allowExpandToggle: false,
                  ),
            FriendWidget(
              user: widget.message['sender'],
              showBorder: false,
              showMessage: widget.message['type'] == 'message',
              message: widget.message,
              showFamilyCheckbox: false,
              allowExpandToggle: false,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                    key: Key(
                        'familyCheckbox-${widget.message["sender"]["email"]}'),
                    value: familyCheckboxValue,
                    onChanged: (bool newValue) async {
                      setState(() {
                        familyCheckboxValue = newValue;
                        print('sgtm familyCheckboxValue: $familyCheckboxValue');
                      });
                      if (widget.onFamilyCheckboxClicked != null) {
                        widget.onFamilyCheckboxClicked(newValue);
                      }
                    }),
                Text(Strings.storiesPageFamily.i18n),
              ],
            ),
            widget.isAudio
                ? Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      children: <Widget>[
                        PlayerWidget(
                          key: Key("playWidget${widget.message['id']}"),
                          url: host(
                            widget.message['key'],
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
                widget.approveButton == null
                    ? Container()
                    : widget.approveButton,
                widget.rejectButton == null ? Container() : widget.rejectButton,
              ],
            )
          ],
        ),
      ),
    );
  }
}
