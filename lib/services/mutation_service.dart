import 'dart:io' as io;

import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:MyFamilyVoice/constants/graphql.dart';

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

  return result.data['uploadFile'];
}

MultipartFile getMultipartFile(
  io.File _file,
  String _fileName,
  String _type,
  String _subType,
) {
  final byteData = _file.readAsBytesSync();

  final multipartFile = MultipartFile.fromBytes(
    _type,
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
  DateTime now = DateTime.now();
  now = now.subtract(Duration(days: daysOffset));

  //Create the Story
  MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(createStory),
    variables: <String, dynamic>{
      'id': storyId,
      'image': imageFilePath,
      'audio': audioFilePath,
      'created': now.toIso8601String(),
      'updated': now.toIso8601String()
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

Future<void> updateStory(
  GraphQLClient graphQLClientApolloServer,
  String storyId,
  String imageFilePath,
  String audioFilePath,
  String created,
) async {
  final DateTime now = DateTime.now();

  //Create the Story
  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(updateStoryQL),
    variables: <String, dynamic>{
      'id': storyId,
      'image': imageFilePath,
      'audio': audioFilePath,
      'created': created,
      'updated': now.toIso8601String()
    },
  );

  final QueryResult queryResult =
      await graphQLClientApolloServer.mutate(_mutationOptions);

  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return;
}

Future<void> deleteStory(
  GraphQLClient graphQLClientApolloServer,
  String storyId,
) async {
  //Create the Story
  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(deleteStoryQL),
    variables: <String, dynamic>{
      'id': storyId,
    },
  );

  final QueryResult queryResult =
      await graphQLClientApolloServer.mutate(_mutationOptions);

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

Future<void> updateUserMessageStatusById(
  GraphQLClient graphQLClient,
  String email,
  String messageId,
  String status,
) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(updateUserMessageStatusByIdQL),
    variables: <String, dynamic>{
      'email': email,
      'id': messageId,
      'status': status,
      'resolved': DateTime.now().toIso8601String(),
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> addUserMessages(
  GraphQLClient graphQLClient,
  String fromUserId,
  String toUserId,
  String messageId,
  String status,
  String text,
  String type,
  String key1,
) async {
  final DateTime now = DateTime.now();
  final MutationOptions options = MutationOptions(
    documentNode: gql(addUserMessagesQL),
    variables: <String, dynamic>{
      'from': fromUserId,
      'to': toUserId,
      'id': messageId,
      'created': now.toIso8601String(),
      'status': status,
      'text': text,
      'type': type,
      'key1': key1
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<QueryResult> updateUserInfo(
  GraphQLClient graphQLClientFileServer,
  GraphQLClient graphQLClient, {
  String jpegPathUrl,
  String id,
  String name,
  String home,
}) async {
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final String formattedDate = formatter.format(now);

  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(updateUser),
    variables: <String, dynamic>{
      'id': id,
      'name': name,
      'home': home,
      'image': jpegPathUrl,
      'updated': formattedDate
    },
  );
  return await graphQLClient.mutate(_mutationOptions);
}

Future<void> createComment(
  GraphQLClient graphQLClient,
  String commentId,
  String storyId,
  String audio,
  String status,
) async {
  final DateTime now = DateTime.now();
  final MutationOptions options = MutationOptions(
    documentNode: gql(createCommentQL),
    variables: <String, dynamic>{
      'commentId': commentId,
      'storyId': storyId,
      'audio': audio,
      'status': status,
      'created': now.toIso8601String()
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> updateComment(
  GraphQLClient graphQLClient,
  String commentId,
  String status,
) async {
  final DateTime now = DateTime.now();
  final MutationOptions options = MutationOptions(
    documentNode: gql(updateCommentQL),
    variables: <String, dynamic>{
      'commentId': commentId,
      'status': status,
      'updated': now.toIso8601String()
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> removeStoryComment(
  GraphQLClient graphQLClient,
  String storyId,
  String commentId,
) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(removeStoryCommentQL),
    variables: <String, dynamic>{
      'storyId': storyId,
      'commentId': commentId,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> deleteComment(
  GraphQLClient graphQLClient,
  String commentId,
) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(deleteCommentQL),
    variables: <String, dynamic>{
      'commentId': commentId,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> mergeCommentFrom(
  GraphQLClient graphQLClient,
  String userId,
  String commentId,
) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(mergeCommentFromQL),
    variables: <String, dynamic>{
      'userId': userId,
      'commentId': commentId,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> addStoryComments(
  GraphQLClient graphQLClient,
  String storyId,
  String commentId,
) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(addStoryCommentsQL),
    variables: <String, dynamic>{
      'storyId': storyId,
      'commentId': commentId,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> deleteUserReactionToStory(
  GraphQLClient graphQLClient,
  String email,
  String storyId,
) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(deleteUserReactionToStoryQL),
    variables: <String, dynamic>{
      'email': email,
      'storyId': storyId,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> createReaction(
  GraphQLClient graphQLClient,
  String id,
  String storyId,
  String type,
) async {
  final DateTime now = DateTime.now();
  final MutationOptions options = MutationOptions(
    documentNode: gql(createReactionQL),
    variables: <String, dynamic>{
      'id': id,
      'storyId': storyId,
      'created': now.toIso8601String(),
      'type': type,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> addReactionFrom(
  GraphQLClient graphQLClient,
  String userId,
  String reactionId,
) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(addReactionFromQL),
    variables: <String, dynamic>{
      'userId': userId,
      'reactionId': reactionId,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> addStoryReaction(
  GraphQLClient graphQLClient,
  String storyId,
  String reactionId,
) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(addStoryReactionQL),
    variables: <String, dynamic>{
      'storyId': storyId,
      'reactionId': reactionId,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> doCommentUploads(BuildContext context, io.File _commentAudio,
    Map<String, dynamic> _story) async {
  final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

  final GraphQLClient graphQLClientFileServer =
      graphQLAuth.getGraphQLClient(GraphQLClientType.FileServer);

  final GraphQLClient graphQLClientApolloServer =
      GraphQLProvider.of(context).value;

  final _uuid = Uuid();
  final String _commentId = _uuid.v1();

  final MultipartFile multipartFile = getMultipartFile(
    _commentAudio,
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
    _story['id'],
    _audioFilePath,
    'new',
  );

  await mergeCommentFrom(
    graphQLClientApolloServer,
    graphQLAuth.getCurrentUserId(),
    _commentId,
  );

  await addStoryComments(
    graphQLClientApolloServer,
    _story['id'],
    _commentId,
  );

  //make sure the updated field gets updated
  await updateStory(
    graphQLClientApolloServer,
    _story['id'],
    _story['image'],
    _story['audio'],
    _story['created']['formatted'],
  );

  await addUserMessages(
    graphQLClientApolloServer,
    graphQLAuth.getCurrentUserId(),
    _story['user']['id'],
    _uuid.v1(),
    'new',
    'Comment',
    'comment',
    _story['id'],
  );
  return;
}
