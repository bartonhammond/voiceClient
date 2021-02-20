import 'package:MyFamilyVoice/ql/node_ql.dart';
import 'package:MyFamilyVoice/ql/story/story_comments.dart';
import 'package:MyFamilyVoice/ql/story/story_original_user.dart';
import 'package:MyFamilyVoice/ql/story/story_reactions.dart';
import 'package:MyFamilyVoice/ql/story/story_tags.dart';
import 'package:MyFamilyVoice/ql/story/story_user.dart';

class StoryQl extends NodeQl {
  StoryQl({
    this.core = true,
    this.storyUser,
    this.storyOriginalUser,
    this.storyComments,
    this.storyReactions,
    this.storyTags,
  });
  bool core;
  StoryUser storyUser;
  StoryOriginalUser storyOriginalUser;
  StoryComments storyComments;
  StoryReactions storyReactions;
  StoryTags storyTags;
  @override
  String get gql {
    String rtn = '';
    if (storyReactions != null) {
      rtn += storyReactions.gql;
    }
    if (core) {
      rtn += coreQL;
    }
    if (storyUser != null) {
      rtn += storyUser.gql;
    }
    if (storyOriginalUser != null) {
      rtn += storyOriginalUser.gql;
    }
    if (storyComments != null) {
      rtn += storyComments.gql;
    }
    if (storyTags != null) {
      rtn += storyTags.gql;
    }

    return rtn;
  }

  final coreQL = r'''
    __typename
    id
    image
    audio
    type
    created {
      formatted
    }
    updated {
      formatted
    }
    ''';
}
