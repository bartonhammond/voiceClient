import 'package:MyFamilyVoice/ql/node_ql.dart';

class StoryComments extends NodeQl {
  StoryComments();
  @override
  String get gql {
    return r''' 
      comments {
        id
        audio
        from {
          id
          name
          email
        }
        created {
          formatted
        }
        status
      }
''';
  }
}
