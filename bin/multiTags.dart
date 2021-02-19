import 'dart:io';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/model/model_base.dart';
import 'package:MyFamilyVoice/services/utilities.dart';
import 'package:args/args.dart';
import 'package:graphql/client.dart';
import '../seed/graphQLClient.dart';

Future<void> main(List<String> arguments) async {
  print('main');
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

  final Map currentUser = <String, dynamic>{
    'id': '208fa390-2c12-11eb-bd5c-472790cf338f', //b@gmail
  };
  final Map taggedUser1 = <String, dynamic>{
    'user': {
      'id': '8e711330-331f-11eb-8a6e-35c4ab11173d', //admin@mfv
    }
  };
  final Map taggedUser2 = <String, dynamic>{
    'user': {
      'id': 'ad749990-5742-11eb-949a-49285ebcd71d', //barton@yahoo
    }
  };
  final Message message1 = Message(
      currentUser: currentUser,
      tag: taggedUser1,
      status: 'new',
      type: 'attention',
      key: 'e2737600-7206-11eb-ba27-2bad43e7d92d' //storyId
      );
  final Message message2 = Message(
      currentUser: currentUser,
      tag: taggedUser2,
      status: 'new',
      type: 'attention',
      key: 'e2737600-7206-11eb-ba27-2bad43e7d92d' //storyId
      );

  final GQLBuilder builder = GQLBuilder('createMessage');
  builder.add(message1);
  builder.add(message2);
  final String _gql = builder.getGQL();
  print(_gql);
  final Map _variables = builder.getVariables();
  printJson('variables', _variables);

  final MutationOptions options = MutationOptions(
    documentNode: gql(_gql),
    variables: _variables,
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }
}
