import 'package:MyFamilyVoice/ql/query.dart';
import 'package:MyFamilyVoice/ql/user_ql.dart';
import 'package:graphql/client.dart';

class UserSearch extends Query {
  UserSearch.init(GraphQLClient graphQLClient, this.userQL, this.substitution)
      : super.init(graphQLClient);
  String substitution;
  Map variables = <String, dynamic>{
    'currentUserEmail': 'String!',
    'searchString': 'String!',
    'limit': 'String!',
    'skip': 'String!'
  };
  UserQl userQL;
  String queryName = 'userSearch';

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
  Future<Map> getItem(Map values) async {
    variables.forEach((dynamic key, dynamic value) {
      assert(values.containsKey(key));
    });
    return await super.getItemFromQuery(graphQLClient, values);
  }

  @override
  Future<List> getList(Map values) async {
    variables.forEach((dynamic key, dynamic value) {
      assert(values.containsKey(key));
    });
    return await super.getListFromQuery(graphQLClient, values);
  }

  @override
  String getGQL() {
    return userQL.gql;
  }

  @override
  String doSubstition(String gql) {
    if (substitution != null) {
      gql = gql.replaceAll(
        RegExp(r'_currentUserEmail_'),
        substitution,
      );
    }
    return gql.replaceAll(
      RegExp(r'_currentUserEmail_'),
      '',
    );
  }

  @override
  void setVariables(Map<String, dynamic> variables) {
    this.variables = variables;
  }
}
