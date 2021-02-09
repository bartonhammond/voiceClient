import 'package:MyFamilyVoice/ql/node_ql.dart';
import 'package:MyFamilyVoice/ql/user_ql.dart';

class StoryOriginalUser extends NodeQl {
  StoryOriginalUser();
  UserQl userQl = UserQl(core: true);

  @override
  String get gql {
    return r''' 
        originalUser {''' +
        userQl.gql +
        r'''} 
''';
  }
}
