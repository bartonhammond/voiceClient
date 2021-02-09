import 'package:MyFamilyVoice/ql/node_ql.dart';
import 'package:MyFamilyVoice/ql/user/user_friends.dart';
import 'package:MyFamilyVoice/ql/user_ql.dart';

class MessageQl extends NodeQl {
  MessageQl({
    this.core = true,
  });
  bool core;
  UserFriends userFriends = UserFriends();

  @override
  String get gql {
    final UserQl userQl = UserQl(
      core: true,
      userFriends: userFriends,
    );
    return r'''
    __typename
    id
    type
    status
    key
    created {
      formatted
    }
    sender {''' +
        userQl.gql +
        r'''} 
    book {''' +
        userQl.gql +
        r'''}''';
  }
}
