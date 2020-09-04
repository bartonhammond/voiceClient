import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';
import 'package:graphql/client.dart';
import 'package:http/http.dart';

import 'package:voiceClient/constants/enums.dart';

import 'Person.dart';
import 'addSingleStory.dart';
import 'addUser.dart';
import 'getPhotoFiles.dart';
import 'graphQLClient.dart';

Future<void> main(List<String> arguments) async {
  final List<dynamic> files = getFiles();
  final parser = ArgParser();
  parser.addOption('mode',
      help: 'which enviroment to run with', allowed: ['dev', 'prod']);

  if (arguments == null || arguments.isEmpty) {
    print('missing arguments');
    print(parser.usage);
    exit(1);
  }

  final ArgResults argResults = parser.parse(arguments);

  final GraphQLClient graphQLClientApolloServer =
      getGraphQLClient(argResults, GraphQLClientType.ApolloServer);

  final GraphQLClient graphQLClientFileServer =
      getGraphQLClient(argResults, GraphQLClientType.FileServer);

  //Create User
  final Random randomVoiceGen = Random();
  final Random randomFileGen = Random();

  final userIds = <String>[];

  for (var userIndex = 0; userIndex < 500; userIndex++) {
    try {
      final Response response =
          await get('https://randomuser.me/api/?format=json&nat=us');
      final dynamic data = json.decode(response.body)['results'][0];

      final Person p = Person.fromJson(data);
      final String userId = await addUser(
        graphQLClientFileServer,
        graphQLClientApolloServer,
        p.toMap(),
      );

      userIds.add(userId);
      print('addUser: $userId');

      //For 10 Stories
      for (var storyIndex = 25; storyIndex > -1; storyIndex--) {
        final Map<String, dynamic> map = p.toMap();
        final String text =
            '${map['name']} from ${map['home']} story number $storyIndex';

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
  return;
}
