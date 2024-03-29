import 'dart:convert';
import 'package:MyFamilyVoice/tags/item_tags.dart';
import 'package:MyFamilyVoice/tags/tags.dart';
import 'package:flutter/material.dart';

class TaggedFriends extends StatefulWidget {
  const TaggedFriends({
    Key key,
    this.onDelete,
    this.items,
  }) : super(key: key);
  final void Function(Map<String, dynamic>) onDelete;
  final List<dynamic> items;

  @override
  _TaggedFriendsState createState() => _TaggedFriendsState();
}

class _TaggedFriendsState extends State<TaggedFriends> {
  @override
  Widget build(BuildContext context) {
    const double _fontSize = 14.0;

    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.all(15.0),
      children: [
        widget.items == null
            ? Container()
            : Tags(
                key: Key('taggedFriend'),
                symmetry: false,
                columns: 0,
                horizontalScroll: false,
                verticalDirection: VerticalDirection.down,
                textDirection: TextDirection.ltr,
                heightHorizontalScroll: 60 * (_fontSize / 14),
                itemCount: widget.items.length,
                itemBuilder: (index) {
                  final dynamic item = widget.items[index];

                  return GestureDetector(
                      child: ItemTags(
                        key: Key('itemTag-${item["user"]["name"]}'),
                        index: index,
                        title: item['user']['name'],
                        pressEnabled: false,
                        activeColor: Color(0xff00bcd4),
                        textColor: Colors.black,
                        textActiveColor: Colors.black,
                        combine: ItemTagsCombine.onlyText,
                        removeButton: widget.onDelete == null
                            ? null
                            : ItemTagsRemoveButton(
                                backgroundColor: Colors.green[900],
                                onRemoved: () {
                                  widget.onDelete(widget.items[index]);
                                  return true;
                                },
                              ),
                        textScaleFactor: utf8
                                    .encode(
                                        item['user']['name'].substring(0, 1))
                                    .length >
                                2
                            ? 0.8
                            : 1,
                        textStyle: TextStyle(
                          fontSize: _fontSize,
                          color: Colors.black,
                        ),
                      ),
                      onTapDown: (details) {});
                },
              ),
      ],
    );
  }
}
