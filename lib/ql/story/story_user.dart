import 'package:MyFamilyVoice/ql/node_ql.dart';
import 'package:MyFamilyVoice/ql/user/user_book_author.dart';
import 'package:MyFamilyVoice/ql/user/user_friends.dart';
import 'package:MyFamilyVoice/ql/user_ql.dart';

class StoryUser extends NodeQl {
  StoryUser();

  UserFriends userFriends = UserFriends();
  UserBookAuthor userBookAuthor = UserBookAuthor();

  @override
  String get gql {
    final UserQl userQl = UserQl(
      core: true,
      userFriends: userFriends,
      userBookAuthor: userBookAuthor,
    );
    return r''' 
        user {''' +
        userQl.gql +
        r'''} 
''';
  }
}
