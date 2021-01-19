import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:args/args.dart';
import 'package:graphql/client.dart';

import '../seed/graphQLClient.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addOption('mode',
      help: 'which enviroment to run with', allowed: ['dev', 'prod']);

  if (arguments == null || arguments.isEmpty) {
    print('missing arguments');
    print(parser.usage);
  }

  final ArgResults argResults = parser.parse(arguments);

  final GraphQLClient graphQLClient =
      getGraphQLClient(argResults, GraphQLClientType.ApolloServer);

  try {
    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(getStoryByIdQL),
      variables: <String, dynamic>{
        'id': '58605b90-5767-11eb-a268-798075c3ce64',
        'currentUserEmail': 'bartonhammond@yahoo.com'
      },
    );

    final QueryResult queryResult = await graphQLClient.query(_queryOptions);
    if (queryResult.hasException) {
      throw queryResult.exception;
    }

    final Map story = queryResult.data['getStoryById'];
    print(story);
  } catch (e) {
    print('sgts.callback faled $e');
  }
}
