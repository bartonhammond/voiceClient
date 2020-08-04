import 'dart:io' as io;

import 'package:graphql/client.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/services/graphql_auth.dart';

Future<dynamic> performMutation(
  GraphQLClient graphQLClient,
  MultipartFile multipartFile,
  String type,
) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(uploadFile),
    variables: <String, dynamic>{
      'file': multipartFile,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);

  if (result.hasException) {
    throw result.exception;
  }

  return result.data['upload'];
}

MultipartFile getMultipartFile(
  io.File _file,
  String _fileName,
  String _type,
  String _subType,
) {
  final byteData = _file.readAsBytesSync();

  final multipartFile = MultipartFile.fromBytes(
    'photo',
    byteData,
    filename: _fileName,
    contentType: MediaType(_type, _subType),
  );
  return multipartFile;
}

Future<void> addStory(
    GraphQLClient graphQLClientApolloServer,
    String currentUserId,
    String storyId,
    String imageFilePath,
    String audioFilePath,
    {int daysOffset = 0}) async {
  print('addStory.daysOffset: $daysOffset');
  DateTime now = DateTime.now();
  now = now.subtract(Duration(days: daysOffset));

  //Create the Story
  MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(createStory),
    variables: <String, dynamic>{
      'id': storyId,
      'image': imageFilePath,
      'audio': audioFilePath,
      'created': now.toIso8601String()
    },
  );

  QueryResult queryResult =
      await graphQLClientApolloServer.mutate(_mutationOptions);

  if (queryResult.hasException) {
    throw queryResult.exception;
  }

  final userInput = {'id': currentUserId};
  final to = {'id': storyId};

  //Merge Story w/ User
  _mutationOptions = MutationOptions(
    documentNode: gql(mergeUserStories),
    variables: <String, dynamic>{
      'from': userInput,
      'to': to,
    },
  );

  queryResult = await graphQLClientApolloServer.mutate(_mutationOptions);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return;
}

Future<void> addUserFriend(
  GraphQLClient graphQLClientApolloServer,
  String fromUserId,
  String toUserId,
) async {
  final uuid = Uuid();
  final String _friendsId = uuid.v1();

  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final String formattedDate = formatter.format(now);

  //Create the Story
  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(mergeUserFriends),
    variables: <String, dynamic>{
      'id': _friendsId,
      'from': fromUserId,
      'to': toUserId,
      'created': formattedDate
    },
  );

  final QueryResult queryResult =
      await graphQLClientApolloServer.mutate(_mutationOptions);

  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return;
}

Future<void> updateFriendRequest(
  GraphQLClient graphQLClient,
  String fromId,
  String toId,
  String messageId,
  String created,
  String status,
  String text,
  String type,
) async {
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final String formattedDate = formatter.format(now);

  final MutationOptions options = MutationOptions(
    documentNode: gql(updateUserMessage),
    variables: <String, dynamic>{
      'from': fromId,
      'to': toId,
      'id': messageId,
      'created': created,
      'resolved': formattedDate,
      'status': status,
      'text': text,
      'type': type,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<QueryResult> createUserMessage(
  GraphQLClient graphQLClient,
  GraphQLAuth graphQLAuth,
  String friendId,
) async {
  final uuid = Uuid();

  final MutationOptions options = MutationOptions(
    documentNode: gql(addUserMessage),
    variables: <String, dynamic>{
      'from': graphQLAuth.getCurrentUserId(),
      'to': friendId,
      'id': uuid.v1(),
      'created': DateTime.now().toIso8601String(),
      'status': 'new',
      'text': 'friend request',
      'type': 'friend-request',
    },
    update: (Cache cache, QueryResult result) {
      if (result.hasException) {
        throw result.exception;
      }
    },
  );
  return await graphQLClient.mutate(options);
}

Future<QueryResult> updateUserInfo(
    GraphQLClient graphQLClientFileServer, GraphQLClient graphQLClient,
    {String jpegPathUrl,
    String id,
    String name,
    String home,
    int birth}) async {
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final String formattedDate = formatter.format(now);

  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(updateUser),
    variables: <String, dynamic>{
      'id': id,
      'name': name,
      'home': home,
      'birth': birth,
      'image': jpegPathUrl,
      'updated': formattedDate
    },
  );
  return await graphQLClient.mutate(_mutationOptions);
}
