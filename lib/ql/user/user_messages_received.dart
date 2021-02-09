import 'package:MyFamilyVoice/ql/node_ql.dart';

class UserMessagesReceived extends NodeQl {
  UserMessagesReceived({
    this.useFilter = true,
  });
  bool useFilter;
  String filter = r'''(filter: {
      status: "new"
      type: "friend-request"
      sender: {
        email: "_currentUserEmail_"
      }
    })''';

  final String _gql = r''' 
    messagesReceived _filter_ {
     	id
      type
      created {
        formatted
      }
      status
      key
      sender {
        id
        email
        name
        home
      }
    }
''';

  @override
  String get gql {
    if (useFilter) {
      return _gql.replaceAll(RegExp(r'_filter_'), filter);
    }
    return _gql.replaceAll(RegExp(r'_filter_'), '');
  }
}
