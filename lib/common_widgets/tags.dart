import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';

import 'package:voiceClient/constants/mfv.i18n.dart';
import 'package:voiceClient/constants/strings.dart';

class TagsWidget extends StatefulWidget {
  const TagsWidget(
      {this.tags,
      this.fontSize = 16,
      this.height = 200,
      this.updatedAble = true});
  final List<String> tags;
  final double fontSize;
  final double height;
  final bool updatedAble;

  @override
  _TagsWidgetState createState() => _TagsWidgetState();
}

class _TagsWidgetState extends State<TagsWidget> {
  TagsTextField getTextField() {
    if (widget.updatedAble) {
      return TagsTextField(
        autofocus: false,
        hintText: Strings.addTagHere.i18n,
        textStyle: TextStyle(
          fontSize: widget.fontSize,

          //height: 1
        ),
        enabled: true,
        constraintSuggestion: false,
        suggestions: null,
        onSubmitted: (String str) {
          setState(() {
            widget.tags.add(str);
          });
        },
      );
    }
    return null;
  }

  ItemTagsRemoveButton getRemoveButton(int index) {
    if (widget.updatedAble) {
      return ItemTagsRemoveButton(
        backgroundColor: Colors.black,
        onRemoved: () {
          setState(() {
            widget.tags.removeAt(index);
          });
          return true;
        },
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const ItemTagsCombine combine = ItemTagsCombine.onlyText;
    return Container(
      child: Tags(
        key: Key('tags'),
        symmetry: false,
        columns: 4,
        horizontalScroll: false,
        verticalDirection: VerticalDirection.up,
        textDirection: TextDirection.rtl,
        heightHorizontalScroll: 60 * (widget.fontSize / 14),
        textField: getTextField(),
        itemCount: widget.tags.length,
        itemBuilder: (index) {
          final String item = widget.tags[index];

          return GestureDetector(
              child: ItemTags(
            key: Key(index.toString()),
            index: index,
            title: item,
            pressEnabled: false,
            activeColor: Color(0xff00bcd4),
            combine: combine,
            image: null,
            icon: null,
            removeButton: getRemoveButton(index),
            textScaleFactor:
                utf8.encode(item.substring(0, 1)).length > 2 ? 0.8 : 1,
            textStyle: TextStyle(
              fontSize: widget.fontSize,
            ),
          ));
        },
      ),
    );
  }
}
