import 'dart:io' as io;
import 'dart:typed_data';
import 'package:MyFamilyVoice/model/model_base.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/utilities.dart';
import 'package:graphql/client.dart';
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
    String type,
    {int daysOffset = 0}) async {
  DateTime now = DateTime.now();
  now = now.subtract(Duration(days: daysOffset));

  //Create the Story
  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(createStory),
    variables: <String, dynamic>{
      'storyId': storyId,
      'image': imageFilePath,
      'audio': audioFilePath,
      'created': now.toIso8601String(),
      'updated': now.toIso8601String(),
      'type': type,
      'userId': currentUserId
    },
  );

  final QueryResult queryResult =
      await graphQLClientApolloServer.mutate(_mutationOptions);

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
  String type,
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
      'updated': now.toIso8601String(),
      'type': type,
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
      'storyId': storyId,
    },
  );

  final QueryResult queryResult =
      await graphQLClientApolloServer.mutate(_mutationOptions);

  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return;
}

Future<void> changeStoriesUser(
  GraphQLClient graphQLClient, {
  String currentUserId,
  String newUserId,
  String storyId,
}) async {
  //Remove  originalUser and replace w/ new user
  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(changeStoryUserQL),
    variables: <String, dynamic>{
      'originalUserId': currentUserId,
      'storyId': storyId,
      'newUserId': newUserId,
    },
  );

  final QueryResult queryResult = await graphQLClient.mutate(_mutationOptions);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }

  return;
}

Future<void> changeStoryUserAndSaveOriginalUser(
  GraphQLClient graphQLClientApolloServer, {
  String currentUserId,
  String storyId,
  String newUserId,
}) async {
  //Save the original user and replace the current user
  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(addStoryOriginalUserQL),
    variables: <String, dynamic>{
      'originalUserId': currentUserId,
      'storyId': storyId,
      'newUserId': newUserId,
    },
  );

  final QueryResult queryResult =
      await graphQLClientApolloServer.mutate(_mutationOptions);

  if (queryResult.hasException) {
    throw queryResult.exception;
  }
}

Future<void> deleteMessage(
  GraphQLClient graphQLClientApolloServer,
  String messageId,
) async {
  //delete the message
  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(deleteMessageQL),
    variables: <String, dynamic>{
      'id': messageId,
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
      'currentUserEmail': email,
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

Future<void> addUserMessages({
  GraphQLClient graphQLClient,
  Map<String, dynamic> fromUser,
  Map<String, dynamic> toUser,
  String messageId,
  String status,
  String type,
  String key,
}) async {
  if (toUser['isBook'] == true) {
    final DateTime now = DateTime.now();
    final MutationOptions options = MutationOptions(
      documentNode: gql(createMessageWithBookQL),
      variables: <String, dynamic>{
        'messageId': messageId,
        'created': now.toIso8601String(),
        'status': status,
        'type': type,
        'key': key,
        'fromUserId': fromUser['id'],
        'toUserId': toUser['bookAuthor']['id'],
        'bookUserId': toUser['id']
      },
    );

    final QueryResult result = await graphQLClient.mutate(options);
    if (result.hasException) {
      throw result.exception;
    }
  } else {
    final DateTime now = DateTime.now();
    final MutationOptions options = MutationOptions(
      documentNode: gql(createMessageQL),
      variables: <String, dynamic>{
        'messageId': messageId,
        'created': now.toIso8601String(),
        'status': status,
        'type': type,
        'key': key,
        'fromUserId': fromUser['id'],
        'toUserId': toUser['id'],
      },
    );

    final QueryResult result = await graphQLClient.mutate(options);
    if (result.hasException) {
      throw result.exception;
    }
  }

  return;
}

Future<QueryResult> createOrUpdateUserInfo(
    bool shouldCreateUser, GraphQLClient graphQLClient,
    {String jpegPathUrl,
    String id,
    String email,
    String name,
    String home,
    bool isBook,
    String bookAuthorId}) async {
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final String formattedDate = formatter.format(now);
  final MutationOptions _mutationOptions = shouldCreateUser
      ? MutationOptions(
          documentNode: gql(createUserQL),
          variables: <String, dynamic>{
              'id': id,
              'email': email,
              'name': name,
              'home': home,
              'image': jpegPathUrl,
              'created': formattedDate,
              'isBook': isBook,
            })
      : MutationOptions(
          documentNode: gql(updateUserQL),
          variables: <String, dynamic>{
              'id': id,
              'name': name,
              'home': home,
              'image': jpegPathUrl,
              'updated': formattedDate,
              'isBook': isBook,
            });

  final QueryResult result = await graphQLClient.mutate(_mutationOptions);

  if (shouldCreateUser && isBook) {
    await addUserBookAuthor(
      graphQLClient,
      id,
      bookAuthorId,
    );
  }
  return result;
}

Future<void> createComment(
  GraphQLClient graphQLClient, {
  String commentId,
  String audio,
  String status,
  String updated,
  String userId,
  String storyId,
}) async {
  final DateTime now = DateTime.now();
  final MutationOptions options = MutationOptions(
    documentNode: gql(createCommentQL),
    variables: <String, dynamic>{
      'commentId': commentId,
      'audio': audio,
      'status': status,
      'updated': now.toIso8601String(),
      'userId': userId,
      'storyId': storyId
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
  GraphQLClient graphQLClient, {
  String reactionId,
  String type,
  String storyId,
  String userId,
}) async {
  final DateTime now = DateTime.now();
  final MutationOptions options = MutationOptions(
    documentNode: gql(createReactionQL),
    variables: <String, dynamic>{
      'reactionId': reactionId,
      'created': now.toIso8601String(),
      'type': type,
      'storyId': storyId,
      'userId': userId,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> changeReaction(
  GraphQLClient graphQLClient, {
  String originalReactionId,
  String reactionId,
  String type,
  String storyId,
  String userId,
}) async {
  final DateTime now = DateTime.now();
  final MutationOptions options = MutationOptions(
    documentNode: gql(changeReactionQL),
    variables: <String, dynamic>{
      'originalReactionId': originalReactionId,
      'reactionId': reactionId,
      'created': now.toIso8601String(),
      'type': type,
      'storyId': storyId,
      'userId': userId,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> doCommentUploads(
    GraphQLAuth graphQLAuth,
    GraphQLClient graphQLClientFileServer,
    GraphQLClient graphQLClientApolloServer,
    Map<String, dynamic> _story,
    {io.File commentAudio,
    Uint8List commentAudioWeb}) async {
  final _uuid = Uuid();
  final String _commentId = _uuid.v1();

  MultipartFile multipartFile;

  if (commentAudio != null) {
    multipartFile = getMultipartFile(
      commentAudio,
      '$_commentId.mp3',
      'audio',
      'mp3',
    );
  }
  if (commentAudioWeb != null) {
    multipartFile = MultipartFile.fromBytes(
      'audio',
      commentAudioWeb,
      filename: '$_commentId.mp3',
      contentType: MediaType('audio', 'mp3'),
    );
  }

  final String _audioFilePath = await performMutation(
    graphQLClientFileServer,
    multipartFile,
    'mp3',
  );

  final DateTime now = DateTime.now();
  await createComment(
    graphQLClientApolloServer,
    commentId: _commentId,
    audio: _audioFilePath,
    status: 'new',
    userId: graphQLAuth.getUserMap()['id'],
    storyId: _story['id'],
    updated: now.toIso8601String(),
  );

  //don't create message if it's your story
  if (graphQLAuth.getUserMap()['id'] == _story['user']['id']) {
    return;
  }

  await addUserMessages(
    graphQLClient: graphQLClientApolloServer,
    fromUser: graphQLAuth.getUserMap(),
    toUser: _story['user'],
    messageId: _uuid.v1(),
    status: 'new',
    type: 'comment',
    key: _story['id'],
  );
  return;
}

Future<void> doMessageUploads(
    GraphQLAuth graphQLAuth,
    GraphQLClient graphQLClientFileServer,
    GraphQLClient graphQLClientApolloServer,
    Map<String, dynamic> toUser,
    {io.File messageAudio,
    Uint8List messageAudioWeb}) async {
  final _uuid = Uuid();
  final String _messageId = _uuid.v1();

  MultipartFile multipartFile;
  if (messageAudio != null) {
    multipartFile = getMultipartFile(
      messageAudio,
      '$_messageId.mp3',
      'audio',
      'mp3',
    );
  }
  if (messageAudioWeb != null) {
    multipartFile = MultipartFile.fromBytes(
      'audio',
      messageAudioWeb,
      filename: '$_messageId.mp3',
      contentType: MediaType(
        'audio',
        'mp3',
      ),
    );
  }

  final String _audioFilePath = await performMutation(
    graphQLClientFileServer,
    multipartFile,
    'mp3',
  );

  await addUserMessages(
    graphQLClient: graphQLClientApolloServer,
    fromUser: graphQLAuth.getUserMap(),
    toUser: toUser,
    messageId: _messageId,
    status: 'new',
    type: 'message',
    key: _audioFilePath,
  );
  return;
}

Future<void> updateUserIsFamily(
  GraphQLClient graphQLClient,
  String emailFrom,
  String emailTo,
  bool isFamily,
) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(updateUserIsFamilyQL),
    variables: <String, dynamic>{
      'emailFrom': emailFrom,
      'emailTo': emailTo,
      'isFamily': isFamily,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }
  return;
}

Future<void> addStoryTagsAndMessages({
  Map<String, dynamic> user,
  GraphQLClient graphQLClient,
  GQLBuilder gqlBuilderTags,
  GQLBuilder gqlBuilderMessages,
  GQLBuilder gqlBuilderMessagesBook,
}) async {
  //Create tags
  if (gqlBuilderTags.hasModels()) {
    final String _gql = gqlBuilderTags.getGQL();
    final Map _variables = gqlBuilderTags.getVariables();
    final MutationOptions options = MutationOptions(
      documentNode: gql(_gql),
      variables: _variables,
    );
    final QueryResult result = await graphQLClient.mutate(options);
    if (result.hasException) {
      throw result.exception;
    }
  }
  //Create messages
  if (gqlBuilderMessages.hasModels()) {
    final String _gql = gqlBuilderMessages.getGQL();
    print('_gql: $_gql');
    final Map _variables = gqlBuilderMessages.getVariables();
    printJson('_variables', _variables);
    final MutationOptions options = MutationOptions(
      documentNode: gql(_gql),
      variables: _variables,
    );
    final QueryResult result = await graphQLClient.mutate(options);
    if (result.hasException) {
      throw result.exception;
    }
  }
  //Create messages for books
  if (gqlBuilderMessagesBook.hasModels()) {
    final String _gql = gqlBuilderMessagesBook.getGQL();
    final Map _variables = gqlBuilderMessagesBook.getVariables();
    final MutationOptions options = MutationOptions(
      documentNode: gql(_gql),
      variables: _variables,
    );
    final QueryResult result = await graphQLClient.mutate(options);
    if (result.hasException) {
      throw result.exception;
    }
  }

  return;
}

Future<void> createTag(
  GraphQLClient graphQLClient, {
  String tagId,
  String storyId,
  String userId,
}) async {
  final DateTime now = DateTime.now();
  final MutationOptions options = MutationOptions(
    documentNode: gql(createTagQL),
    variables: <String, dynamic>{
      'tagId': tagId,
      'created': now.toIso8601String(),
      'storyId': storyId,
      'userId': userId,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> deleteStoryTags(
  GraphQLClient graphQLClient,
  String storyId,
) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(deleteStoriesTagsQL),
    variables: <String, dynamic>{
      'storyId': storyId,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> deleteBook(
  GraphQLClient graphQLClientApolloServer,
  String email,
) async {
  //Create the Story
  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(deleteBookQL),
    variables: <String, dynamic>{
      'email': email,
    },
  );

  final QueryResult queryResult =
      await graphQLClientApolloServer.mutate(_mutationOptions);

  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return;
}

Future<void> addBanned(
  GraphQLClient graphQLClient,
  String fromUserId,
  String toUserId,
) async {
  final uuid = Uuid();
  final banId = uuid.v1();
  final DateTime now = DateTime.now();

  //Create ban, banner and banned
  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(createBanQL),
    variables: <String, dynamic>{
      'banId': banId,
      'bannerId': fromUserId,
      'bannedId': toUserId,
      'created': now.toIso8601String(),
    },
  );
  final QueryResult result = await graphQLClient.mutate(_mutationOptions);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> deleteBanned(
  GraphQLClient graphQLClientApolloServer,
  String banId,
) async {
  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(deleteBanQL),
    variables: <String, dynamic>{
      'id': banId,
    },
  );

  final QueryResult queryResult =
      await graphQLClientApolloServer.mutate(_mutationOptions);

  if (queryResult.hasException) {
    throw queryResult.exception;
  }

  return;
}

Future<void> addUserBookAuthor(
  GraphQLClient graphQLClient,
  String fromUserId,
  String toUserId,
) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(addUserBookAuthorQL),
    variables: <String, dynamic>{
      'from': fromUserId,
      'to': toUserId,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }
  return;
}

Future<void> addUserFriendsServerSide(
  GraphQLClient graphQLClient, {
  String userId1,
  String userId2,
  bool isFamily1To2,
  bool isFamily2To1,
  bool isFamily,
}) async {
  final Uuid uuid = Uuid();
  final DateTime now = DateTime.now();
  //Create the Story
  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(addUserFriendsQL),
    variables: <String, dynamic>{
      'friendId1': uuid.v1(),
      'friendId2': uuid.v1(),
      'created': now.toIso8601String(),
      'userId1': userId1,
      'userId2': userId2,
      'isFamily1': isFamily1To2,
      'isFamily2': isFamily2To1,
    },
  );

  final QueryResult queryResult = await graphQLClient.mutate(_mutationOptions);

  if (queryResult.hasException) {
    throw queryResult.exception;
  }

  return;
}

Future<void> quitFriendship(
  GraphQLClient graphQLClient, {
  String friendId1,
  String friendId2,
}) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(deleteFriendsQL),
    variables: <String, dynamic>{
      'friendId1': friendId1,
      'friendId2': friendId2,
    },
  );

  final QueryResult queryResult = await graphQLClient.mutate(options);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return;
}
