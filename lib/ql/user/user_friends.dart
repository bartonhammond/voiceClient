import 'package:MyFamilyVoice/ql/node_ql.dart';

class UserFriends extends NodeQl {
  UserFriends({
    this.useFilter = true,
  });
  bool useFilter;
  String filter = r'''(filter: { 
        User: { 
          email: "_currentUserEmail_" 
        } 
      })''';

  final _gql = r'''
    friends {
      to _filter_ {
        id
        isFamily
        User {
          email
        }
      }
    }
  ''';

  @override
  String get gql {
    if (useFilter) {
      return _gql.replaceAll(RegExp(r'_filter_'), filter);
    }
    return _gql;
  }
}
