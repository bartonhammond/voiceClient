import 'package:MyFamilyVoice/ql/query.dart';
import 'package:MyFamilyVoice/ql/story_ql.dart';

import 'package:graphql/client.dart';

class StorySearch extends Query {
  StorySearch.init(
    GraphQLClient graphQLClient,
    this.storyQL,
    this.substitution,
  ) : super.init(graphQLClient);
  String substitution;
  Map variables = <String, dynamic>{
    'currentUserEmail': 'String!',
    'limit': 'String!',
    'cursor': 'String!'
  };
  StoryQl storyQL;
  String queryName = 'userFriendsStories';

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
    return storyQL.gql;
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
