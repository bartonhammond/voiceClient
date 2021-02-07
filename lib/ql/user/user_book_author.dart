import 'package:MyFamilyVoice/ql/node_ql.dart';
import 'package:MyFamilyVoice/ql/user/user_ban.dart';
import 'package:MyFamilyVoice/ql/user/user_friends.dart';
import 'package:MyFamilyVoice/ql/user/user_messages_received.dart';
import 'package:MyFamilyVoice/ql/user_ql.dart';

class UserBookAuthor extends NodeQl {
  UserBookAuthor({
    this.useFilter = true,
  });
  bool useFilter;

  UserMessagesReceived userMessagesReceived = UserMessagesReceived();
  UserFriends userFriends = UserFriends();
  UserBan userBan = UserBan();

  String filter = r'''(filter: { 
        User: { 
          email: "_currentUserEmail_" 
        } 
      })''';

  @override
  String get gql {
    final UserQl userQl = UserQl(
      userBan: userBan,
      userFriends: userFriends,
      userMessagesReceived: userMessagesReceived,
    );

    final String _gql = r'''
    bookAuthor {''' +
        userQl.gql +
        r'''}
    ''';

    if (useFilter) {
      return _gql.replaceAll(RegExp(r'_filter_'), filter);
    }
    return _gql;
  }
}
