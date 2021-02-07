import 'package:MyFamilyVoice/ql/node_ql.dart';
import 'package:MyFamilyVoice/ql/user_ql.dart';

class MessageQl extends NodeQl {
  MessageQl({
    this.core = true,
  });
  bool core;
  UserQl userQl = UserQl(core: true);

  @override
  String get gql {
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
