import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';
import 'package:graphql/client.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/services/mutation_service.dart';

import 'addComments.dart';
import 'addSingleStory.dart';
import 'addUser.dart';
import 'constants.dart';
import 'getPhotoFiles.dart';
import 'graphQLClient.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addOption('mode',
      help: 'which enviroment to run with', allowed: ['dev', 'prod']);

  if (arguments == null || arguments.isEmpty) {
    print('missing arguments');
    print(parser.getUsage());
    exit(1);
  }

  ArgResults argResults = parser.parse(arguments);

  final userIds = <String>[];
  final users = [
    {
      'email': 'karenhammond@gmail.com',
      'announce': 'She hails for Durango but she has lived everywhere',
      'name': 'Karen Hammond',
      'home': 'Durango, CO',
      'birth': 1952,
      'profile': 'karen'
    },
    {
      'email': 'bartonhammond@gmail.com',
      'announce': 'The great man behind the key board',
      'name': 'Barton Hammond',
      'home': 'Fond du Lac, WI',
      'birth': 1954,
      'profile': 'barton'
    },
    {
      'email': 'charleshammond@gmail.com',
      'announce': 'Most honored son and all around great guy',
      'name': 'Charles Hammond',
      'home': 'Austin, TX',
      'birth': 1960,
      'profile': 'charles'
    },
    {
      'email': 'marilynhammond@gmail.com',
      'announce': 'The highly esteemed and greatly loved and admired',
      'name': 'Marilyn Hammond',
      'home': 'Fond du Lac, WI',
      'birth': 1950,
      'profile': 'marilyn'
    },
    {
      'email': 'emilyhammond@gmail.com',
      'announce': 'Most wonderful daughter and thoughtful wife',
      'name': 'Emily Hammond',
      'birth': 1964,
      'home': 'Austin, TX',
      'profile': 'emily'
    },
    {
      'email': 'neufy@gmail.com',
      'announce': 'The ninth dog, the french magician, the butterfly',
      'name': 'Neufy',
      'birth': 2019,
      'home': 'Fond du Lac, WI',
      'profile': 'neufy'
    },
    {
      'email': 'felina@gmail.com',
      'announce': 'From the cat who brings joy to everyone',
      'name': 'Felina',
      'birth': 2012,
      'home': 'Fond du Lac, WI',
      'profile': 'felina'
    },
    {
      'email': 'lily@gmail.com',
      'announce': 'the fastest, quickest, lure coursing Afghan Hound',
      'name': 'lily',
      'birth': 1980,
      'home': 'Tulsa, OK',
      'profile': 'lily'
    },
    {
      'email': 'cala@gmail.com',
      'announce': 'The sweetest greyhound, the great traveler',
      'name': 'cala',
      'home': 'Tulsa, OK',
      'birth': 1982,
      'profile': 'cala'
    },
    {
      'email': 'lordnatolie@gmail.com',
      'announce': 'The fastest greyhound Lord Natolie',
      'name': 'Lord Natolie',
      'home': 'Austin, TX',
      'profile': 'natolie',
      'birth': 1985
    },
    {
      'email': 'peggyhammond@gmail.com',
      'announce': 'The greatest mom ever, we miss her so much',
      'name': 'Peggy Hammond',
      'home': 'Gonzales, CA',
      'profile': 'peggy',
      'birth': 1934
    },
    {
      'email': 'ermahammond@gmail.com',
      'announce': 'Fantastic sister, mother and wife',
      'name': 'Erma Hammond',
      'profile': 'erma',
      'birth': 1950,
      'home': 'Bend, OR'
    },
    {
      'email': 'thomhammond@gmail.com',
      'announce': 'Fantastic nephew and college graduate',
      'name': 'Thom Hammond',
      'profile': 'thom',
      'birth': 1990,
      'home': 'Richmond, CA'
    },
    {
      'email': 'brucefreeman@gmail.com',
      'announce': 'He is not here, but he is always remembered',
      'name': 'Bruce Freeman',
      'profile': 'bruce',
      'birth': 1950,
      'home': 'El Sobrante, CA'
    },
  ];

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
