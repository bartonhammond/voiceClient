import 'package:MyFamilyVoice/ql/query.dart';
import 'package:MyFamilyVoice/ql/reaction_ql.dart';
import 'package:graphql/client.dart';

class ReactionSearch extends Query {
  ReactionSearch.init(
    GraphQLClient graphQLClient,
    this.reactionQl,
    this.substitution,
  ) : super.init(graphQLClient);
  String substitution;
  Map variables = <String, dynamic>{
    'id': 'String!',
    'currentUserEmail': 'String!',
  };

  ReactionQl reactionQl;
  String queryName = 'storyReactions';

  @override
  void setQueryName(String queryName) {
    this.queryName = queryName;
  }

  @override
  String getQueryName() {
    return queryName;
  }

  @override
  Map<String, dynamic> getVariables() {
    return variables;
  }

  @override
  Future<List> getList(Map values) async {
    variables.forEach((dynamic key, dynamic value) {
      assert(values.containsKey(key));
    });
    return await super.getListFromQuery(graphQLClient, values);
  }

  @override
  Future<Map> getItem(Map values) async {
    variables.forEach((dynamic key, dynamic value) {
      assert(values.containsKey(key));
    });
    return await super.getItemFromQuery(graphQLClient, values);
  }

  @override
  String getGQL() {
    return reactionQl.gql;
  }

  @override
  String doSubstition(String gql) {
    if (substitution != null) {
      gql = gql.replaceAll(
        RegExp(r'_currentUserEmail_'),
        substitution,
      );
    }
    return gql;
  }

  @override
  void setVariables(Map<String, dynamic> variables) {
    this.variables = variables;
  }
}
