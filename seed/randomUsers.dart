import 'dart:convert';
import 'dart:math';

import 'package:graphql/client.dart';
import 'package:http/http.dart';
import 'package:voiceClient/constants/enums.dart';

import 'Person.dart';
import 'addSingleStory.dart';
import 'addUser.dart';
import 'getPhotoFiles.dart';
import 'graphQLClient.dart';

Future<void> main() async {
  final List<dynamic> files = getFiles();

  final GraphQLClient graphQLClientApolloServer =
      getGraphQLClient(GraphQLClientType.ApolloServer);

  final GraphQLClient graphQLClientFileServer =
      getGraphQLClient(GraphQLClientType.FileServer);

  //Create User
  final Random randomVoiceGen = Random();
  final Random randomFileGen = Random();

  final userIds = <String>[];

  for (var userIndex = 0; userIndex < 100; userIndex++) {
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
      for (var storyIndex = 10; storyIndex > -1; storyIndex--) {
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
