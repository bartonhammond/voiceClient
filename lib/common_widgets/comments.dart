import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:MyFamilyVoice/common_widgets/player_widget.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/host.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';

class Comments extends StatelessWidget {
  Comments({
    Key key,
    this.story,
    this.fontSize = 10,
    this.showExpand = false,
    this.onClickDelete,
    this.isWeb,
  }) : super(key: key);
  final bool isWeb;
  final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

  final Map<String, dynamic> story;
  final double fontSize;
  final bool showExpand;
  final Function(Map<String, dynamic> comment) onClickDelete;

  Widget _getCommentDetail(Map<String, dynamic> comment, double fontSize) {
    final DateTime dt = DateTime.parse(comment['created']['formatted']);
    final DateFormat df = DateFormat.yMd().add_jm();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PlayerWidget(
          key: Key("playWidget${comment['id']}"),
          url: host(comment['audio']),
          showSlider: isWeb ? false : true,
        ),
        Text(
          comment['from']['name'],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
        ),
        Text(
          df.format(dt),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
        ),
        getExpandedContainer(comment),
      ],
    );
  }

  Widget getExpandedContainer(Map<String, dynamic> comment) {
    if (showExpand) {
      //1 If it's your story,
      //2 or its your book
      //3 or you are the bookAuthor
      //4 or you made the comment
      if (/*1*/ (graphQLAuth.getUserMap()['id'] == story['user']['id']) ||
          (/*2*/ story['user']['isBook'] &&
              story['user']['bookAuthor']['id'] ==
                  graphQLAuth.getUserMap()['id']) ||
          (/*3*/ story['user']['isBook'] &&
              story['originalUser']['id'] == graphQLAuth.getUserMap()['id']) ||
          /*4*/ graphQLAuth.getUserMap()['id'] == comment['from']['id']) {
        return ConfigurableExpansionTile(
          animatedWidgetFollowingHeader: const Icon(
            Icons.expand_more,
            color: Color(0xff00bcd4),
          ),
          header: Container(
              color: Colors.transparent,
              child: Center(
                  child: Text('', style: TextStyle(color: Color(0xff00bcd4))))),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  child: Text(
                    Strings.deleteComment.i18n,
                    style: TextStyle(
                      color: Color(0xff00bcd4),
                      fontSize: 16.0,
                    ),
                  ),
                  onTap: () {
                    onClickDelete(comment);
                  },
                )
              ],
            )
          ],
        );
      }
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    if (story == null) {
      return Container();
    }
    List<dynamic> comments = story['comments'];

    comments = comments
        .where((dynamic comment) => comment['status'] == 'new')
        .toList();

    if (comments.isEmpty) {
      return Container();
    }

    comments.sort((dynamic a, dynamic b) =>
        a['created']['formatted'].compareTo(b['created']['formatted']));

    final List<Widget> _comments = <Widget>[];
    for (var i = 0; i < comments.length; i++) {
      _comments.add(_getCommentDetail(comments[i], fontSize));
      if (i < comments.length - 1) {
        _comments.add(Container(
          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          height: 1,
          color: Colors.black,
        ));
      }
    }
    double heightContainer = 200;
    if (_comments.length > 1) {
      heightContainer = 300;
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(0xff00bcd4),
        ),
      ),
      height: heightContainer,
      width: 200,
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
