import 'dart:math';

import 'package:graphql/client.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/services/mutation_service.dart';

import 'addSingleStory.dart';
import 'addUser.dart';
import 'getPhotoFiles.dart';
import 'graphQLClient.dart';

Future<void> main() async {
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
      getGraphQLClient(GraphQLClientType.ApolloServer);

  final GraphQLClient graphQLClientFileServer =
      getGraphQLClient(GraphQLClientType.FileServer);

  //Create User
  final Random randomVoiceGen = Random();
  final Random randomFileGen = Random();

  for (var userIndex = 0; userIndex < users.length; userIndex++) {
    try {
      final String userId = await addUser(
        graphQLClientFileServer,
        graphQLClientApolloServer,
        users[userIndex],
      );
      userIds.add(userId);
      print('addUser: $userId');

      //For 10 Stories
      for (var storyIndex = 25; storyIndex > -1; storyIndex--) {
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
      }
    } catch (e) {
      print('Exception voiceSeed: $e.toString()');
    }
  }

  //Make everyone friends
  for (var userIndex = 0; userIndex < 8; userIndex++) {
    for (var friendIndex = 0; friendIndex < 8; friendIndex++) {
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
  return;
}
