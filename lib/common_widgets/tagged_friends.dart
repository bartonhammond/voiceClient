import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';

class TaggedFriends extends StatefulWidget {
  const TaggedFriends({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _TaggedFriendsState createState() => _TaggedFriendsState();
}

class _TaggedFriendsState extends State<TaggedFriends> {
  final List<String> _items = [
    'Barton Hammond',
    'Marilyn Hammond',
    'Charles Hammond',
    'Emily Hammond'
  ];
  @override
  Widget build(BuildContext context) {
    const double _fontSize = 14.0;

    return Tags(
      key: Key('taggedFriend'),
      symmetry: false,
      columns: 0,
      horizontalScroll: false,
      verticalDirection: VerticalDirection.down,
      textDirection: TextDirection.ltr,
      heightHorizontalScroll: 60 * (_fontSize / 14),
      itemCount: _items.length,
      itemBuilder: (index) {
        final item = _items[index];

        return GestureDetector(
            child: ItemTags(
              key: Key(index.toString()),
              index: index,
              title: item,
              pressEnabled: false,
              activeColor: Colors.green[400],
              combine: ItemTagsCombine.onlyText,
              removeButton: ItemTagsRemoveButton(
                backgroundColor: Colors.green[900],
                onRemoved: () {
                  setState(() {
                    _items.removeAt(index);
                  });
                  return true;
                },
              ),
              textScaleFactor:
                  utf8.encode(item.substring(0, 1)).length > 2 ? 0.8 : 1,
              textStyle: TextStyle(
                fontSize: _fontSize,
              ),
            ),
            onTapDown: (details) {});
      },
    );
  }
}
