import 'package:MyFamilyVoice/ql/node_ql.dart';

class UserFriends extends NodeQl {
  UserFriends({
    this.useFilter = true,
  });
  bool useFilter;
  String filterTo = r'''(filter: { 
        receiver: { 
          email: "_currentUserEmail_" 
        } 
      })''';
  String filterFrom = r'''(filter: { 
        sender: { 
          email: "_currentUserEmail_" 
        } 
      })''';

  final _gql = r'''
    friendsTo _filterTo_ {
      id
      isFamily
      receiver {
        id
        name
        email
      }
    }
    friendsFrom _filterFrom_ {
      id
      isFamily
      sender {
        id
        name
        email
      }
    }
    
  ''';

  @override
  String get gql {
    if (useFilter) {
      return _gql
          .replaceAll(RegExp(r'_filterTo_'), filterTo)
          .replaceAll(RegExp(r'_filterFrom_'), filterFrom);
    }
    return _gql
        .replaceAll(RegExp(r'_filterTo_'), '')
        .replaceAll(RegExp(r'_filterFrom_'), '');
  }
}
