import 'package:graphql/client.dart';

abstract class Query {
  Query.init(
    this.graphQLClient,
  );

  GraphQLClient graphQLClient;
  void setQueryName(String queryName);
  String getQueryName();

  //Definition of variables
  Map<String, dynamic> getVariables();

  void setVariables(Map<String, dynamic> variables);

  //get the specific gql
  String getGQL();

  //public faceing
  Future<List> getList(
    Map values,
  );

  //public facing
  Future<Map> getItem(
    Map values,
  );

  String doSubstition(String gql);

  String getGQLString() {
    String gqlString = 'query ${getQueryName()}(';
    getVariables().forEach((dynamic key, dynamic value) {
      gqlString += '\$$key: $value, ';
    });
    gqlString += ') {\n';
    gqlString += '${getQueryName()}(';
    getVariables().forEach((dynamic key, dynamic value) {
      gqlString += '$key: \$$key, ';
    });
    gqlString += '){\n';
    gqlString += getGQL();
    gqlString += '}\n}\n';
    return gqlString;
  }

  QueryOptions getQueryOptions(Map values) {
    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(doSubstition(getGQLString())),
      variables: values,
    );
    return _queryOptions;
  }

  Future<List> getListFromQuery(
    GraphQLClient graphQLClient,
    Map values,
  ) async {
    final QueryOptions _queryOptions = getQueryOptions(values);
    final QueryResult queryResult = await graphQLClient.query(_queryOptions);
    if (queryResult.hasException) {
      throw queryResult.exception;
    }
    return queryResult.data[getQueryName()];
  }

  Future<Map> getItemFromQuery(GraphQLClient graphQLClient, Map values) async {
    final QueryOptions _queryOptions = getQueryOptions(values);
    final QueryResult queryResult = await graphQLClient.query(_queryOptions);
    if (queryResult.hasException) {
      throw queryResult.exception;
    }
    return queryResult.data[getQueryName()];
  }
}
