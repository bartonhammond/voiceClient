import 'dart:io' as io;
import 'dart:typed_data';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/queries_service.dart';
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
  MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(createStory),
    variables: <String, dynamic>{
      'id': storyId,
      'image': imageFilePath,
      'audio': audioFilePath,
      'created': now.toIso8601String(),
      'updated': now.toIso8601String(),
      'type': type,
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
  GraphQLClient graphQLClientApolloServer,
  String currentUserId,
  String newUserId,
  String storyId,
) async {
  var userInput = {'id': currentUserId};
  final to = {'id': storyId};

  //Remove  Story w/ User
  MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(removeUserStories),
    variables: <String, dynamic>{
      'from': userInput,
      'to': to,
    },
  );

  QueryResult queryResult =
      await graphQLClientApolloServer.mutate(_mutationOptions);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }

  //Merge Story w/ new user
  userInput = {'id': newUserId};

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

Future<void> addStoryOriginalUser(
  GraphQLClient graphQLClientApolloServer,
  String currentUserId,
  String storyId,
) async {
  final userInput = {'id': currentUserId};
  final to = {'id': storyId};

  //Remove  Story w/ User
  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(addStoryOriginalUserQL),
    variables: <String, dynamic>{
      'from': userInput,
      'to': to,
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
  String storyId,
) async {
  //delete the message
  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(deleteMessageQL),
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

Future<void> _addUserMessages(
  GraphQLClient graphQLClient,
  Map<String, dynamic> fromUser,
  Map<String, dynamic> toUser,
  String messageId,
  String status,
  String type,
  String key1,
  String key2,
) async {
  final DateTime now = DateTime.now();
  MutationOptions options = MutationOptions(
    documentNode: gql(createMessageQL),
    variables: <String, dynamic>{
      'id': messageId,
      'created': now.toIso8601String(),
      'status': status,
      'type': type,
      'key1': key1,
      'key2': key2,
      'fromEmail': fromUser['email'],
      'toEmail': toUser['email'],
    },
  );

  QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  //create from
  final String fromUserId = fromUser['id'];
  final _fromUser = {'id': fromUserId};
  final _toMessage = {'id': messageId};

  options = MutationOptions(
    documentNode: gql(addUserMessagesSentQL),
    variables: <String, dynamic>{
      'from': _fromUser,
      'to': _toMessage,
    },
  );
  result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }
  //create to
  final String toUserId = toUser['id'];
  final _toUser = {'id': toUserId};
  final _fromMessage = {'id': messageId};

  options = MutationOptions(
    documentNode: gql(addUserMessagesReceivedQL),
    variables: <String, dynamic>{
      'to': _toUser,
      'from': _fromMessage,
      'currentUserEmail': fromUser['email']
    },
  );
  result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }
  return;
}

Future<void> addUserMessages(
  GraphQLClient graphQLClient,
  Map<String, dynamic> fromUser,
  Map<String, dynamic> toUser,
  String messageId,
  String status,
  String type,
  String key1,
  String key2,
) async {
  await _addUserMessages(
    graphQLClient,
    fromUser,
    toUser,
    messageId,
    status,
    type,
    key1,
    key2,
  );
  //A message type 'manage' will be
  //from the book
  if (toUser['isBook'] == true) {
    final QueryResult result = await getUserMessagesReceived(
      graphQLClient,
      toUser['bookAuthor']['email'],
      DateTime.now().toIso8601String(),
    );

    //look for type an existing manage
    bool foundManageTypeForUser = false;
    for (var message in result.data['userMessagesReceived']) {
      if (message['type'] == 'manage' && message['status'] == 'new') {
        foundManageTypeForUser = true;
        break;
      }
    }
    if (!foundManageTypeForUser) {
      final Map user = await getUserByEmail(
        graphQLClient,
        toUser['bookAuthor']['email'],
      );
      final _messageId = Uuid().v1();
      await _addUserMessages(
        graphQLClient,
        toUser, //the book
        user, // the books author
        _messageId,
        'new',
        'manage',
        key1,
        user['email'],
      );
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

  await createComment(
    graphQLClientApolloServer,
    _commentId,
    _story['id'],
    _audioFilePath,
    'new',
  );

  await mergeCommentFrom(
    graphQLClientApolloServer,
    graphQLAuth.getUserMap()['id'],
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
    _story['type'],
  );

  //don't create message if it's your story
  if (graphQLAuth.getUserMap()['id'] == _story['user']['id']) {
    return;
  }

  await addUserMessages(
    graphQLClientApolloServer,
    graphQLAuth.getUserMap(),
    _story['user'],
    _uuid.v1(),
    'new',
    'comment',
    _story['id'],
    _story['user']['email'],
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
    graphQLClientApolloServer,
    graphQLAuth.getUserMap(),
    toUser,
    _messageId,
    'new',
    'message',
    _audioFilePath,
    toUser['email'],
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

Future<void> addStoryTag(
  Map<String, dynamic> user,
  GraphQLClient graphQLClient,
  Map<String, dynamic> _story,
  Map<String, dynamic> _tag,
) async {
  final _uuid = Uuid();
  final String _tagId = _uuid.v1();

  await createTag(
    graphQLClient,
    _tagId,
    _story['id'],
  );

  await addStoryTags(
    graphQLClient,
    _story['id'],
    _tagId,
  );

  await addUserTags(
    graphQLClient,
    _tag['user']['id'],
    _tagId,
  );

  await addUserMessages(
    graphQLClient,
    user,
    _tag['user'],
    _uuid.v1(),
    'new',
    'attention',
    _story['id'],
    _tag['user']['email'],
  );

  return;
}

Future<void> createTag(
  GraphQLClient graphQLClient,
  String tagId,
  String storyId,
) async {
  final DateTime now = DateTime.now();
  final MutationOptions options = MutationOptions(
    documentNode: gql(createTagQL),
    variables: <String, dynamic>{
      'tagId': tagId,
      'storyId': storyId,
      'created': now.toIso8601String()
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> addStoryTags(
  GraphQLClient graphQLClient,
  String storyId,
  String tagId,
) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(addStoryTagsQL),
    variables: <String, dynamic>{
      'storyId': storyId,
      'tagId': tagId,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> addUserTags(
  GraphQLClient graphQLClient,
  String userId,
  String tagId,
) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(addUserTagsQL),
    variables: <String, dynamic>{
      'userId': userId,
      'tagId': tagId,
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

Future<void> addUserBanned(
  GraphQLClient graphQLClientApolloServer,
  String fromUserId,
  String toUserId,
) async {
  //Create the Ban
  final uuid = Uuid();
  final String _bannedId = uuid.v1();
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final String formattedDate = formatter.format(now);

  final fromUserInput = {'id': fromUserId};
  final toUserInput = {'id': toUserId};
  final data = {
    'id': _bannedId,
    'created': {'formatted': formattedDate}
  };
  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(addUserBannedQL),
    variables: <String, dynamic>{
      'from': fromUserInput,
      'to': toUserInput,
      'data': data,
    },
  );
  final QueryResult queryResult =
      await graphQLClientApolloServer.mutate(_mutationOptions);

  if (queryResult.hasException) {
    throw queryResult.exception;
  }

  return;
}

Future<void> removeUserBanned(
  GraphQLClient graphQLClientApolloServer,
  String fromUserId,
  String toUserId,
) async {
  final fromUserInput = {'id': fromUserId};
  final toUserInput = {'id': toUserId};

  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(removeUserBannedQL),
    variables: <String, dynamic>{
      'from': fromUserInput,
      'to': toUserInput,
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
