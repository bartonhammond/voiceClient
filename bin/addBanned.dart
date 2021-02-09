import 'dart:io';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:graphql/client.dart';
import 'package:uuid/uuid.dart';
import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:args/args.dart';
import '../seed/graphQLClient.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addOption('mode',
      help: 'which enviroment to run with', allowed: ['dev', 'prod']);

  parser.addOption('fromUserId', help: 'From userID');
  parser.addOption('toUserId', help: 'To userId');

  if (arguments == null || arguments.isEmpty) {
    print('missing arguments');
    print(parser.usage);
    exit(1);
  }
  final ArgResults argResults = parser.parse(arguments);

  final GraphQLClient graphQLClient =
      getGraphQLClient(argResults, GraphQLClientType.ApolloServer);

  await addBanned(
    graphQLClient,
    argResults['fromUserId'],
    argResults['toUserId'],
  );
}

Future<Map<String, dynamic>> addBanned(
  GraphQLClient graphQLClient,
  String fromUserId,
  String toUserId,
) async {
  final uuid = Uuid();
  final banId = uuid.v1();
  final DateTime now = DateTime.now();

  //Create ban
  MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(createBanQL),
    variables: <String, dynamic>{
      'banId': banId,
      'created': now.toIso8601String(),
    },
  );
  QueryResult result = await graphQLClient.mutate(_mutationOptions);
  if (result.hasException) {
    throw result.exception;
  }

  //Create banner
  _mutationOptions = MutationOptions(
    documentNode: gql(addBanBannerQL),
    variables: <String, dynamic>{
      'toBanId': banId,
      'fromUserId': fromUserId,
    },
  );
  result = await graphQLClient.mutate(_mutationOptions);
  if (result.hasException) {
    throw result.exception;
  }

//Create banned
  _mutationOptions = MutationOptions(
    documentNode: gql(addBanBannedQL),
    variables: <String, dynamic>{
      'fromBanId': banId,
      'toUserId': toUserId,
    },
  );
  result = await graphQLClient.mutate(_mutationOptions);
  if (result.hasException) {
    throw result.exception;
  }

  return result.data[0];
}
