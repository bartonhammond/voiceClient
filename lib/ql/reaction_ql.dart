import 'package:MyFamilyVoice/ql/node_ql.dart';
import 'package:MyFamilyVoice/ql/user/user_friends.dart';
import 'package:MyFamilyVoice/ql/user_ql.dart';

class ReactionQl extends NodeQl {
  ReactionQl({
    this.core = true,
  });
  bool core;

  UserFriends userFriends = UserFriends(useFilter: true);

  @override
  String get gql {
    final UserQl userQl = UserQl(
      core: true,
      userFriends: userFriends,
    );
    return r'''
    id
    story {
      id
    }
    from {''' +
        userQl.gql +
        r'''}
    created {
      formatted
    }
    type
    updated {
      formatted
    }
  ''';
  }
}
