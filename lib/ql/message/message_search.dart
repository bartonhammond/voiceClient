import 'package:MyFamilyVoice/ql/message_ql.dart';
import 'package:MyFamilyVoice/ql/query.dart';
import 'package:graphql/client.dart';

class MessageSearch extends Query {
  MessageSearch.init(
    GraphQLClient graphQLClient,
    this.reactionQl,
    this.substitution,
  ) : super.init(graphQLClient);
  String substitution;

  Map variables = <String, dynamic>{
    'currentUserEmail': 'String!',
    'status': 'String!',
    'limit': 'String!',
    'cursor': 'String!'
  };

  MessageQl reactionQl;
  String queryName = 'userMessagesReceived';

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
