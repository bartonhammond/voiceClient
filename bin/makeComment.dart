import 'dart:io';
import 'package:args/args.dart';
import 'package:graphql/client.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/services/mutation_service.dart';
import '../seed/graphQLClient.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addOption('mode',
      help: 'which enviroment to run with', allowed: ['dev', 'prod']);

  if (arguments == null || arguments.isEmpty) {
    print('missing arguments');
    print(parser.usage);
    exit(1);
  }

  final ArgResults argResults = parser.parse(arguments);

  final GraphQLClient graphQLClient =
      getGraphQLClient(argResults, GraphQLClientType.ApolloServer);

  //Make everyone friends

  final String storyUserId =
      await _getUserIdByEmail(graphQLClient, 'bartonhammond@gmail.com');

  final String commenterUserId =
      await _getUserIdByEmail(graphQLClient, 'brucefreeman@gmail.com');

  const String storyId = 'e44ab8d0-ed45-11ea-8678-7da3b3f67897';

  await createUserMessage(
    graphQLClient,
    commenterUserId,
    storyUserId,
    'Comment',
    'comment',
    storyId,
  );
}

Future<String> _getUserIdByEmail(
  GraphQLClient graphQLClient,
  String email,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(getUserByEmail),
    variables: <String, dynamic>{
      'email': email,
    },
  );
  final QueryResult queryResult = await graphQLClient.query(_queryOptions);
  return queryResult.data['User'][0]['id'];
}
