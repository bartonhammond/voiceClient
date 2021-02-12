import 'dart:io';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/ql/user_ql.dart';
import 'package:MyFamilyVoice/ql/user/user_book_author.dart';
import 'package:MyFamilyVoice/ql/user/user_friends.dart';
import 'package:MyFamilyVoice/ql/user/user_messages_received.dart';
import 'package:MyFamilyVoice/ql/user/user_search.dart';
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

  final UserBookAuthor userBookAuthor = UserBookAuthor();

  final UserFriends userFriends = UserFriends();

  final UserMessagesReceived userMessagesReceived =
      UserMessagesReceived(useFilter: true);

  final UserQl userQL = UserQl(
    userMessagesReceived: userMessagesReceived,
    userFriends: userFriends,
    userBookAuthor: userBookAuthor,
  );

  final UserSearch userSearch = UserSearch.init(
    graphQLClient,
    userQL,
    'bartonhammond@gmail.com',
  );
  userSearch.setQueryName('getUserByEmail');
  userSearch.setVariables(<String, dynamic>{
    'currentUserEmail': 'String!',
  });

  final Map user = await userSearch.getItem(<String, dynamic>{
    'currentUserEmail': 'ba06c590-68d9-11eb-bb0f-b9c0bc16898b',
  });

  printJson('${user["name"]}', user);
}
