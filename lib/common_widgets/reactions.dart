import 'package:flutter/material.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';

final defaultInitialReaction = Reaction(
  id: 0,
  icon: Text('Like'),
);

final reactions = [
  Reaction(
    id: 1,
    previewIcon: _buildPreviewIconFacebook('assets/images/thumbsup.png'),
    icon: _buildIconFacebook(
      'assets/images/like.png',
      Text(
        'Like',
        style: TextStyle(
          color: Color(0XFF3b5998),
        ),
      ),
    ),
  ),
  Reaction(
    id: 2,
    previewIcon: _buildPreviewIconFacebook('assets/images/haha.png'),
    icon: _buildIconFacebook(
      'assets/images/haha.png',
      Text(
        'Haha',
        style: TextStyle(
          color: Color(0XFFed5168),
        ),
      ),
    ),
  ),
  Reaction(
    id: 3,
    previewIcon: _buildPreviewIconFacebook('assets/images/joy.png'),
    icon: _buildIconFacebook(
      'assets/images/joy.png',
      Text(
        'Joy',
        style: TextStyle(
          color: Color(0XFFffda6b),
        ),
      ),
    ),
  ),
  Reaction(
    id: 4,
    previewIcon: _buildPreviewIconFacebook('assets/images/wow.png'),
    icon: _buildIconFacebook(
      'assets/images/wow.png',
      Text(
        'Wow',
        style: TextStyle(
          color: Color(0XFFffda6b),
        ),
      ),
    ),
  ),
  Reaction(
    id: 5,
    previewIcon: _buildPreviewIconFacebook('assets/images/sad.png'),
    icon: _buildIconFacebook(
      'assets/images/sad.png',
      Text(
        'Sad',
        style: TextStyle(
          color: Color(0XFFffda6b),
        ),
      ),
    ),
  ),
  Reaction(
    id: 6,
    previewIcon: _buildPreviewIconFacebook('assets/images/love.png'),
    icon: _buildIconFacebook(
      'assets/images/love.png',
      Text(
        'Love',
        style: TextStyle(
          color: Color(0XFFf05766),
        ),
      ),
    ),
  ),
];

Widget _buildPreviewIconFacebook(String path) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.5, vertical: 5),
      child: Image.asset(path, height: 40),
    );

Widget _buildIconFacebook(String path, Text text) => Container(
      color: Colors.transparent,
      child: Row(
        children: <Widget>[
          Image.asset(path, height: 20),
          const SizedBox(width: 5),
          text,
        ],
      ),
    );
