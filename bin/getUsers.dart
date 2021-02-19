import 'dart:io';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/ql/user/user_ban.dart';
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
  final UserMessagesReceived userMessagesReceived = UserMessagesReceived();
  final UserBan userBan = UserBan();

  final UserQl userQL = UserQl(
    userBookAuthor: userBookAuthor,
    userMessagesReceived: userMessagesReceived,
    userFriends: userFriends,
    userBan: userBan,
  );

  final UserSearch userSearch = UserSearch.init(
    graphQLClient,
    userQL,
    'familystoryprovider@myfamilyvoice.com',
  );
  final Map searchValues = <String, dynamic>{
    'currentUserEmail': 'familystoryprovider@myfamilyvoice.com',
    'searchString': '*',
    'limit': '10',
    'skip': '0'
  };

  final List users = await userSearch.getList(searchValues);
  for (var user in users) {
    printJson('${user["name"]}', user);
  }
}
