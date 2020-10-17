import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';

import 'package:MyFamilyVoice/constants/mfv.i18n.dart';
import 'package:MyFamilyVoice/constants/strings.dart';

Widget getTags({
  @required List<String> allTags,
  @required List<String> tags,
  @required void Function(String) onTagAdd,
  @required void Function(int) onTagRemove,
  double fontSize = 16,
  double height = 200,
  bool updatedAble = true,
  bool showTagsOnly = false,
}) {
  TagsTextField getTextField() {
    if (updatedAble) {
      return TagsTextField(
        autofocus: false,
        hintText: Strings.addTagHere.i18n,
        textStyle: TextStyle(
          fontSize: fontSize,
        ),
        enabled: true,
        constraintSuggestion: false,
        suggestions: null,
        onSubmitted: onTagAdd,
      );
    } else {
      return null;
    }
  }

  ItemTagsRemoveButton getRemoveButton(int index) {
    if (updatedAble) {
      return ItemTagsRemoveButton(
          backgroundColor: Colors.black,
          onRemoved: () {
            onTagRemove(index);
            return true;
          });
    }
    return null;
  }

  return Tags(
    key: Key('tags'),
    symmetry: false,
    columns: 4,
    horizontalScroll: false,
    verticalDirection: VerticalDirection.up,
    textDirection: TextDirection.rtl,
    heightHorizontalScroll: 60 * (fontSize / 14),
    textField: showTagsOnly ? null : getTextField(),
    itemCount: tags.length,
    itemBuilder: (index) {
      final String item = tags[index];

      return GestureDetector(
          child: ItemTags(
        key: Key(index.toString()),
        index: index,
        title: item,
        pressEnabled: false,
        activeColor: Color(0xff00bcd4),
        combine: ItemTagsCombine.onlyText,
        image: null,
        icon: null,
        removeButton: getRemoveButton(index),
        textScaleFactor: utf8.encode(item.substring(0, 1)).length > 2 ? 0.8 : 1,
        textStyle: TextStyle(
          fontSize: fontSize,
        ),
      ));
    },
  );
}
