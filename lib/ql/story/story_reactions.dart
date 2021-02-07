import 'package:MyFamilyVoice/ql/node_ql.dart';

class StoryReactions extends NodeQl {
  StoryReactions({this.useFilter = false});
  bool useFilter;
  String filter = r'''
    (filter: { from: { email: "_currentUserEmail_"	} } )
    ''';
  @override
  String get gql {
    if (useFilter) {
      return _gql.replaceAll(RegExp(r'_filter_'), filter);
    }
    return _gql;
  }

  final String _gql = r'''
    reactions _filter_ {
      id
      type
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
