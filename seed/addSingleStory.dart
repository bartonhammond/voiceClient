import 'dart:io';
import 'dart:math';

import 'package:graphql/client.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart';
import 'package:voiceClient/services/mutation_service.dart';

import 'constants.dart';
import 'text_to_speech.dart';

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

  final int maxFile = files.length - 1;
  final int randomFile = randomFileGen.nextInt(maxFile);
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

  //Create mp3 (userName, text, file)
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
