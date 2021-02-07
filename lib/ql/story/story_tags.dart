import 'package:MyFamilyVoice/ql/node_ql.dart';

class StoryTags extends NodeQl {
  StoryTags();
  @override
  String get gql {
    return r''' 
    tags {
      id
      created {
        formatted
      }
      user {
        id
        name
        email
      }
    }
''';
  }
}
