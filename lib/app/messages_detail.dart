import 'package:MyFamilyVoice/common_widgets/staggered_grid_tile_story.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';

class MessagesDetail extends StatefulWidget {
  const MessagesDetail({
    Key key,
    this.story,
    this.openComments = false,
  }) : super(key: key);
  final Map story;
  final bool openComments;
  @override
  State<StatefulWidget> createState() => MessagesDetailState();
}

class MessagesDetailState extends State<MessagesDetail> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Color(0xff00bcd4),
          title: Text(Strings.MFV.i18n),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: StaggeredGridTileStory(
                    onBanned: null,
                    onDelete: null,
                    onPush: null,
                    showFriend: true,
                    story: widget.story,
                    openComments: widget.openComments,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
