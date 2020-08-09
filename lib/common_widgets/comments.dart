import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:voiceClient/common_widgets/player_widget.dart';

class Comments extends StatelessWidget {
  const Comments(
      {Key key, this.story, this.fontSize = 10, this.showExpand = false})
      : super(key: key);
  final Map<String, dynamic> story;
  final double fontSize;
  final bool showExpand;

  Widget _getCommentDetail(Map<String, dynamic> comment, double fontSize) {
    final DateTime dt = DateTime.parse(comment['created']['formatted']);
    final DateFormat df = DateFormat.yMd().add_jm();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            PlayerWidget(
              key: Key("playWidget${comment['id']}"),
              url: comment['audio'],
              showSlider: false,
            ),
          ],
        ),
        Text(
          comment['from']['name'],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
        ),
        Text(
          df.format(dt),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
        ),
        showExpand
            ? ConfigurableExpansionTile(
                animatedWidgetFollowingHeader: const Icon(
                  Icons.expand_more,
                  color: Color(0xff00bcd4),
                ),
                header: Container(
                    color: Colors.transparent,
                    child: Center(
                        child: Text('',
                            style: TextStyle(color: Color(0xff00bcd4))))),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[Text('Delete')],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[Text('Hide')],
                  )
                ],
              )
            : Container(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> comments = story['comments'];
    if (comments.isEmpty) {
      return Container();
    }

    comments.sort((dynamic a, dynamic b) =>
        a['created']['formatted'].compareTo(b['created']['formatted']));

    final List<Widget> _comments = <Widget>[];
    for (var i = 0; i < comments.length; i++) {
      _comments.add(_getCommentDetail(comments[i], fontSize));
      if (i < comments.length - 1) {
        _comments.add(Divider(
          thickness: 3.0,
        ));
      }
    }
    double heightContainer = 100;
    if (_comments.length > 1) {
      heightContainer = 200;
    }
    return Container(
      height: heightContainer,
      child: Scrollbar(
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _comments.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              child: _comments[index],
            );
          },
        ),
      ),
    );
  }
}
