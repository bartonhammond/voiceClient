import 'dart:io';
import 'dart:math';

import 'package:graphql/client.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/services/mutation_service.dart';

import 'constants.dart';
import 'text_to_speech.dart';
//import 'package:uuid/uuid.dart';
//import 'package:voiceClient/constants/enums.dart';
//import 'package:voiceClient/constants/graphql.dart';
//import 'package:voiceClient/services/graphql_auth.dart';

Future<void> main() async {
  final userIds = <String>[];
  final emails = [
    'bartonhammond@gmail.com',
    'charleshammond@gmail.com',
    'marilynhammond@gmail.com',
    'emilyhammond@gmail.com',
    'neufy@gmail.com',
    'felina@gmail.com',
    'lily@gmail.com',
    'cala@gmail.com',
    'lordnatolie@gmail.com',
    'peggyhammond@gmail.com',
    'ermahammond@gmail.com'
  ];

  final names = [
    'The great Barton Hammond',
    'Most honored son Charles Hammond',
    'The highly esteemed Miss Marilyn Hammond',
    'Most wonderful daughter Emily Hammond',
    'The one and only Neufy',
    'Most precious Felina',
    'Greatest Afghan Hound Lily',
    'Sweetest greyhound Cala',
    'The fastest greyhound Lord Natolie',
    'The greatest mom ever, miss peggy hammond',
    'Miss Erma Hammond, the one, the only, the best'
  ];
  final List<dynamic> files = getFiles();

  final GraphQLClient graphQLClientApolloServer =
      getGraphQLClient(GraphQLClientType.ApolloServer);

  final GraphQLClient graphQLClientFileServer =
      getGraphQLClient(GraphQLClientType.FileServer);

  //Create User
  final Random randomVoiceGen = Random();
  final Random randomFileGen = Random();

  for (var userIndex = 0; userIndex < emails.length; userIndex++) {
    try {
      final String userId = await addUser(
        graphQLClientApolloServer,
        emails[userIndex],
      );
      userIds.add(userId);
      print('addUser: $userId');

      //For 10 Stories
      for (var storyIndex = 25; storyIndex > -1; storyIndex--) {
        final String text = '${names[userIndex]} story number $storyIndex';

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
  for (var userIndex = 0; userIndex < emails.length; userIndex++) {
    for (var friendIndex = 0; friendIndex < emails.length; friendIndex++) {
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

Future<String> addSingleStory(
    String userId,
    List<dynamic> files,
    GraphQLClient graphQLClientApolloServer,
    GraphQLClient graphQLClientFileServer,
    Random randomFileGen,
    Random randomVoiceGen,
    String text,
    {int daysOffset = 0}) async {
  final uuid = Uuid();
  final String _storyId = uuid.v1();
  //Create Image

  final int randomFile = randomFileGen.nextInt(files.length);
  MultipartFile multipartFile = getMultipartFile(
    File(files[randomFile]),
    '$_storyId.jpg',
    'image',
    'jpeg',
  );

  final String jpegPathUrl = await performMutation(
    graphQLClientFileServer,
    multipartFile,
    'jpeg',
  );
  print('jpegPathUrl: $jpegPathUrl');

  //Create MP3 (userName, text, file)
  final int randomVoice = randomVoiceGen.nextInt(encodings.length);
  final String mp3Path = './seed/mp3/${text.replaceAll(RegExp(' +'), '_')}';
  print('Text: $text');
  print('mp3Path: $mp3Path');

  await textToSpeech(
    text,
    '$mp3Path',
    encodings[randomVoice].substring(0, 5).toLowerCase(),
    encodings[randomVoice],
  );

  multipartFile = getMultipartFile(
    File('$mp3Path.mp3'),
    '$_storyId.mp3',
    'audio',
    'mp3',
  );

  final String mp3PathUrl = await performMutation(
    graphQLClientFileServer,
    multipartFile,
    'mp3',
  );
  print('mp3PathUrl: $mp3PathUrl');

  await addStory(
    graphQLClientApolloServer,
    userId,
    _storyId,
    jpegPathUrl,
    mp3PathUrl,
    daysOffset: daysOffset,
  );

  return _storyId;
}

Future<String> addUser(GraphQLClient graphQLClient, String email) async {
  final uuid = Uuid();
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final String formattedDate = formatter.format(now);
  final String id = uuid.v1();
  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(createUser),
    variables: <String, dynamic>{
      'id': id,
      'email': email,
      'created': formattedDate
    },
  );
  final QueryResult result = await graphQLClient.mutate(_mutationOptions);
  if (result.hasException) {
    throw result.exception;
  }
  return id;
}

List<dynamic> getFiles() {
  final files = <dynamic>[];
  final Directory dir = Directory('./seed/photos');
  // execute an action on each entry
  dir.listSync(recursive: true).forEach((f) {
    if (f.path.endsWith('jpg')) {
      files.add(f.path.toString());
    }
  });
  return files;
}

GraphQLClient getGraphQLClient(GraphQLClientType type) {
  var port = '4003'; //this one is not secured
  var endPoint = 'graphql';

  const uri = 'http://192.168.1.39'; //HP

  if (type == GraphQLClientType.FileServer) {
    port = '4002';
    endPoint = 'query';
  }
  final httpLink = HttpLink(
    uri: '$uri:$port/$endPoint',
  );

  final GraphQLClient graphQLClient = GraphQLClient(
    cache: InMemoryCache(),
    link: httpLink,
  );

  return graphQLClient;
}
