import 'package:MyFamilyVoice/ql/node_ql.dart';
import 'package:MyFamilyVoice/ql/user_ql.dart';

class StoryUser extends NodeQl {
  StoryUser();
  UserQl userQl = UserQl(core: true);

  @override
  String get gql {
    return r''' 
        user {''' +
        userQl.gql +
        r'''} 
''';
  }
}
