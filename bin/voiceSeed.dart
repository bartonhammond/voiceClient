import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';
import 'package:graphql/client.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/services/mutation_service.dart';

import '../seed/addComments.dart';
import '../seed/addSingleStory.dart';
import '../seed/addUser.dart';
import '../seed/constants.dart';
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
  final Random randomTagGen = Random();
  final Random randomCommentGen = Random();
  final Random randomUserGen = Random();

  final List<String> allTags = tags.replaceAll('\n/', '').split(' ');

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
  //Create the system wide tags
  for (var i = 0; i < allTags.length; i++) {
    if (allTags[i].isNotEmpty && allTags[i].length > 5) {
      await addHashTag(
        graphQLClientApolloServer,
        allTags[i],
      );
      print('add tag: ${allTags[i]}');
    }
  }

  //Make stories
  for (var userIndex = 0; userIndex < 1 /*users.length*/; userIndex++) {
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

        final int maxTag = allTags.length - 1;

        for (var i = 0; i < 5; i++) {
          final int randomTag = randomTagGen.nextInt(maxTag);
          if (allTags[randomTag].isNotEmpty && allTags[randomTag].length > 5) {
            await addStoryHashtags(
              graphQLClientApolloServer,
              storyId,
              allTags[randomTag],
            );
            print('add story $storyId, tag: ${allTags[randomTag]}');
          }
        }

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
