import 'package:MyFamilyVoice/ql/node_ql.dart';

class StoryReactions extends NodeQl {
  StoryReactions({this.useFilter = true});
  bool useFilter;
  String filter = r'''
    (filter: { from: { email: "_currentUserEmail_"	} } )
    ''';
  @override
  String get gql {
    if (useFilter) {
      return _gql.replaceAll(RegExp(r'_filter_'), filter);
    }
    return _gql.replaceAll(RegExp(r'_filter_'), '');
  }

  final String _gql = r'''
    reactions _filter_ {
      id
      type 
      from {
        id
        email
        name
      }
    }
    totalReactions
    totalLikes
    totalWows
    totalJoys
    totalHahas
    totalSads
    totalLoves
''';
}
