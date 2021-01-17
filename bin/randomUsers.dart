import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';
import 'package:graphql/client.dart';
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';

import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/services/mutation_service.dart';

import '../seed/Person.dart';
import '../seed/addSingleStory.dart';
import '../seed/addUser.dart';
import '../seed/getPhotoFiles.dart';
import '../seed/graphQLClient.dart';
import '../seed/queries.dart' as q;
import '../seed/voiceUsers.dart';

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
      final List<String> parts = p.email.split('@');
      final String tmp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fresh = tmp.substring(tmp.length - 5);
      p.email = '${parts[0]}$fresh@${parts[1]}';

      final user = await addUser(
        graphQLClientFileServer,
        graphQLClientApolloServer,
        p.toMap(),
      );
      await Future<dynamic>.delayed(Duration(seconds: 1));
      userIds.add(user['id']);
      print('addUser: ${p.email} ${user["id"]}');
      final uuid = Uuid();
      for (var _userIndex = 0; _userIndex < users.length; _userIndex++) {
        final Map<String, dynamic> _user = await q.getUserByEmail(
            graphQLClientApolloServer,
            users[_userIndex]['email'],
            'bartonhammond@gmail.com');
        await addUserFriend(
          graphQLClientApolloServer,
          user['id'],
          _user['id'],
        );
        await addUserFriend(
          graphQLClientApolloServer,
          _user['id'],
          user['id'],
        );
        await addUserMessages(
          graphQLClientApolloServer,
          user,
          _user,
          uuid.v1(),
          'new',
          'Friend Request',
          'friend-request',
          null,
          users[_userIndex]['email'],
        );
        await addUserMessages(
          graphQLClientApolloServer,
          user,
          _user,
          uuid.v1(),
          'new',
          'comment',
          'comment',
          null,
          users[_userIndex]['email'],
        );
      }
      //For 10 Stories
      for (var storyIndex = 15; storyIndex > -1; storyIndex--) {
        final Map<String, dynamic> map = p.toMap();
        final String text =
            '${map['name']} from ${map['home']} story number $storyIndex';

        //Create Story
        await Future<dynamic>.delayed(Duration(seconds: 1));
        final storyId = await addSingleStory(
            user['id'],
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
