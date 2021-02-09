import 'package:MyFamilyVoice/ql/node_ql.dart';
import 'package:MyFamilyVoice/ql/user_ql.dart';

class UserBan extends NodeQl {
  UserBan({
    this.useFilter = false,
  });
  bool useFilter;
  UserQl userQl = UserQl();

  String filter = r'''(filter: { 
        banner: { 
          email: "_currentUserEmail_" 
        } 
      })''';

  @override
  String get gql {
    final String _gql = r'''      
    banned {
      id
      banner{''' +
        userQl.gql +
        r''' 
      }
    } 
''';
    if (useFilter) {
      return _gql.replaceAll(RegExp(r'_filter_'), filter);
    }
    return _gql.replaceAll(RegExp(r'_filter_'), '');
  }
}
