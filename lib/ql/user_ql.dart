import 'package:MyFamilyVoice/ql/node_ql.dart';
import 'package:MyFamilyVoice/ql/user/user_ban.dart';
import 'package:MyFamilyVoice/ql/user/user_book_author.dart';
import 'package:MyFamilyVoice/ql/user/user_friends.dart';
import 'package:MyFamilyVoice/ql/user/user_messages_received.dart';

class UserQl extends NodeQl {
  UserQl({
    this.core = true,
    this.friends = true,
    this.userFriends,
    this.userMessagesReceived,
    this.userBookAuthor,
    this.userBan,
  });
  bool core;
  bool friends;
  UserFriends userFriends;
  UserMessagesReceived userMessagesReceived;
  UserBookAuthor userBookAuthor;
  UserBan userBan;
  @override
  String get gql {
    String rtn = '';
    if (core) {
      rtn += coreQL;
    }
    if (userMessagesReceived != null) {
      rtn += userMessagesReceived.gql;
    }

    if (userBan != null) {
      rtn += userBan.gql;
    }
    //Note: friends has to be after usermessages otherwise
    //the query fails to process the filter on usermessages
    if (userFriends != null) {
      rtn += userFriends.gql;
    }
    if (userBookAuthor != null) {
      rtn += userBookAuthor.gql;
    }
    return rtn;
  }

  final coreQL = r'''
    __typename
    id
    email
    name
    home
    tokens
    image
    isBook
    created {
      formatted
    }
    updated {
      formatted
    }
  ''';
}
