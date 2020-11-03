import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';

final defaultInitialReaction = Reaction(
  id: 0,
  title: _buildTitle(Strings.reactionLike.i18n),
  icon: Container(
    color: Colors.transparent,
    child: Row(
      children: <Widget>[
        Icon(
          MdiIcons.thumbUpOutline,
          size: 20,
        ),
        const SizedBox(width: 5),
        Text(Strings.reactionLike.i18n),
      ],
    ),
  ),
);

final reactions = [
  Reaction(
    id: 1,
    title: _buildTitle(Strings.reactionLike.i18n),
    previewIcon: _buildPreviewIconFacebook('assets/images/like.png'),
    icon: _buildReactionsIcon(
      'assets/images/like.png',
      Text(
        Strings.reactionLike.i18n,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    ),
  ),
  Reaction(
    id: 2,
    title: _buildTitle(Strings.reactionHaha.i18n),
    previewIcon: _buildPreviewIconFacebook('assets/images/haha.png'),
    icon: _buildReactionsIcon(
      'assets/images/haha.png',
      Text(
        Strings.reactionHaha.i18n,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    ),
  ),
  Reaction(
    id: 3,
    title: _buildTitle(Strings.reactionJoy.i18n),
    previewIcon: _buildPreviewIconFacebook('assets/images/joy.png'),
    icon: _buildReactionsIcon(
      'assets/images/joy.png',
      Text(
        Strings.reactionJoy.i18n,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    ),
  ),
  Reaction(
    id: 4,
    title: _buildTitle(Strings.reactionWow.i18n),
    previewIcon: _buildPreviewIconFacebook('assets/images/wow.png'),
    icon: _buildReactionsIcon(
      'assets/images/wow.png',
      Text(
        Strings.reactionWow.i18n,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    ),
  ),
  Reaction(
    id: 5,
    title: _buildTitle(Strings.reactionSad.i18n),
    previewIcon: _buildPreviewIconFacebook('assets/images/sad.png'),
    icon: _buildReactionsIcon(
      'assets/images/sad.png',
      Text(
        Strings.reactionSad.i18n,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    ),
  ),
  Reaction(
    id: 6,
    title: _buildTitle(Strings.reactionLove.i18n),
    previewIcon: _buildPreviewIconFacebook('assets/images/love.png'),
    icon: _buildReactionsIcon(
      'assets/images/love.png',
      Text(
        Strings.reactionLove.i18n,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    ),
  ),
];

Widget _buildTitle(String title) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Color(0xff00bcd4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        title,
        style: TextStyle(color: Colors.black, fontSize: 15),
      ),
    );

Widget _buildPreviewIconFacebook(String path) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.5, vertical: 5),
      child: Image.asset(path, height: 40),
    );

Widget _buildReactionsIcon(String path, Text text) => Container(
      color: Colors.transparent,
      child: Row(
        children: <Widget>[
          Image.asset(path, height: 20),
          const SizedBox(width: 5),
          text,
        ],
      ),
    );
