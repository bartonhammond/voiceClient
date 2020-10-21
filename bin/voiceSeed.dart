import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';
import 'package:graphql/client.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/services/mutation_service.dart';

import '../seed/addComments.dart';
import '../seed/addSingleStory.dart';
import '../seed/addUser.dart';
import '../seed/getPhotoFiles.dart';
import '../seed/graphQLClient.dart';
import '../seed/voiceUsers.dart';

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

  final userIds = <String>[];

  final List<dynamic> files = getFiles();

  final GraphQLClient graphQLClientApolloServer =
      getGraphQLClient(argResults, GraphQLClientType.ApolloServer);

  final GraphQLClient graphQLClientFileServer =
      getGraphQLClient(argResults, GraphQLClientType.FileServer);

  //Create User
  final Random randomVoiceGen = Random();
  final Random randomFileGen = Random();
  final Random randomCommentGen = Random();
  final Random randomUserGen = Random();

  for (var userIndex = 0; userIndex < users.length; userIndex++) {
    try {
      final String userId = await addUser(
        graphQLClientFileServer,
        graphQLClientApolloServer,
        users[userIndex],
      );
      userIds.add(userId);
      print('addUser: $userId');
    } catch (e) {
      print(e);
    }
  } //for

  //Make everyone friends
  for (var userIndex = 0; userIndex < users.length; userIndex++) {
    for (var friendIndex = 0; friendIndex < users.length; friendIndex++) {
      if (userIndex == friendIndex) {
        continue;
      }
      await addUserFriend(
        graphQLClientApolloServer,
        userIds[userIndex],
        userIds[friendIndex],
      );
    }
  }

  //Make stories
  for (var userIndex = 0; userIndex < users.length; userIndex++) {
    try {
      for (var storyIndex = 25; storyIndex > -1; storyIndex--) {
        final String userId = userIds[userIndex];
        final String text =
            '${users[userIndex]['announce']} ${users[userIndex]['name']} from ${users[userIndex]['home']} story number $storyIndex';

        //Create Story
        final storyId = await addSingleStory(
            userId,
            files,
            graphQLClientApolloServer,
            graphQLClientFileServer,
            randomFileGen,
            randomVoiceGen,
            text,
            daysOffset: storyIndex);

        print('addStory: $storyId');

        final int randomComments = randomCommentGen.nextInt(5);

        for (var i = 0; i < randomComments; i++) {
          final int randomUserIndex = randomUserGen.nextInt(users.length);
          final String text =
              '${users[randomUserIndex]['name']} commented on story $storyIndex written by ${users[userIndex]['name']} from ${users[userIndex]['home']}';

          await addComments(
            graphQLClientApolloServer,
            graphQLClientFileServer,
            storyId,
            userIds[randomUserIndex],
            randomVoiceGen,
            text,
          );
          print('added comments');
        }
      }
    } catch (e) {
      print('Exception voiceSeed: $e.toString()');
    }
  }

  return;
}
