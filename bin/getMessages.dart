import 'dart:io';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/ql/message/message_search.dart';
import 'package:MyFamilyVoice/ql/message_ql.dart';
import 'package:MyFamilyVoice/services/utilities.dart';
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
    exit(1);
  }
  final ArgResults argResults = parser.parse(arguments);

  final GraphQLClient graphQLClient =
      getGraphQLClient(argResults, GraphQLClientType.ApolloServer);

  final MessageQl messageQl = MessageQl(
    core: true,
  );

  final MessageSearch messageSearch = MessageSearch.init(
    graphQLClient,
    messageQl,
    'bartonhammond@gmail.com',
  );

  final _values = <String, dynamic>{
    'currentUserEmail': 'bartonhammond@gmail.com',
    'status': 'new',
    'limit': '20',
    'cursor': '2022-02-02',
  };
  try {
    final List messages = await messageSearch.getList(_values);
    print('messages ${messages.length}');
    for (var message in messages) {
      printJson('${message["id"]}', message);
    }
  } catch (e) {
    print(e);
  }
}
