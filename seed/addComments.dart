import 'dart:io';
import 'dart:math';

import 'package:graphql/client.dart';
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';

import 'package:MyFamilyVoice/services/mutation_service.dart';

import 'constants.dart';
import 'text_to_speech.dart';

Future<void> addComments(
  GraphQLClient graphQLClientApolloServer,
  GraphQLClient graphQLClientFileServer,
  String _storyId,
  String _userId,
  Random randomVoiceGen,
  String text,
) async {
  final int randomVoice = randomVoiceGen.nextInt(encodings.length);
  final String mp3Path = './seed/mp3/${text.replaceAll(RegExp(' +'), '_')}';
  final uuid = Uuid();

  final String _commentId = uuid.v1();

  await textToSpeech(
    text,
    '$mp3Path',
    encodings[randomVoice].substring(0, 5).toLowerCase(),
    encodings[randomVoice],
  );

  final MultipartFile multipartFile = getMultipartFile(
    File('$mp3Path.mp3'),
    '$_commentId.mp3',
    'audio',
    'mp3',
  );

  final String _audioFilePath = await performMutation(
    graphQLClientFileServer,
    multipartFile,
    'mp3',
  );

  await createComment(
    graphQLClientApolloServer,
    _commentId,
    _storyId,
    _audioFilePath,
    'new',
  );
  await mergeCommentFrom(
    graphQLClientApolloServer,
    _userId,
    _commentId,
  );

  await addStoryComments(
    graphQLClientApolloServer,
    _storyId,
    _commentId,
  );
}
