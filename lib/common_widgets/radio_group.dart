import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';

class RadioGroup extends StatefulWidget {
  const RadioGroup({
    @required this.storyType,
    @required this.onSelect,
  });
  final StoryType storyType;
  final Function(StoryType) onSelect;
  @override
  RadioGroupWidget createState() => RadioGroupWidget();
}

class RadioGroupWidget extends State<RadioGroup> {
  StoryType _storyType;
  @override
  void initState() {
    super.initState();
    _storyType = widget.storyType;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Radio<StoryType>(
              key: Key('radioGroupFriends'),
              value: StoryType.FRIENDS,
              groupValue: _storyType,
              onChanged: (StoryType val) {
                setState(() {
                  _storyType = val;
                  widget.onSelect(val);
                });
              },
            ),
            Text(
              Strings.storiesPageFriends.i18n,
              style: TextStyle(fontSize: 17.0),
            ),
            Radio<StoryType>(
              key: Key('radioGroupFamily'),
              value: StoryType.FAMILY,
              groupValue: _storyType,
              onChanged: (val) {
                setState(() {
                  _storyType = val;
                  widget.onSelect(val);
                });
              },
            ),
            Text(
              Strings.storiesPageFamily.i18n,
              style: TextStyle(
                fontSize: 17.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
