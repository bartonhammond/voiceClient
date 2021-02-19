import 'package:MyFamilyVoice/ql/story/story_comments.dart';
import 'package:MyFamilyVoice/ql/story/story_original_user.dart';
import 'package:MyFamilyVoice/ql/story/story_reactions.dart';
import 'package:MyFamilyVoice/ql/story/story_search.dart';
import 'package:MyFamilyVoice/ql/story/story_tags.dart';
import 'package:MyFamilyVoice/ql/story/story_user.dart';
import 'package:MyFamilyVoice/ql/story_ql.dart';
import 'package:MyFamilyVoice/ql/user/user_friends.dart';
import 'package:MyFamilyVoice/ql/user/user_search.dart';
import 'package:MyFamilyVoice/ql/user_ql.dart';
import 'package:MyFamilyVoice/services/utilities.dart';
import 'package:graphql/client.dart';
import '../graphQL.dart' as graphql;

Future<void> deleteScenarioAllBasic(GraphQLClient graphQLClient) async {
  try {
    await deleteTestOne(graphQLClient);
  } catch (e) {
    print('deleteTestOne failed');
    print(e);
    rethrow;
  }

  try {
    await deleteTestUser(graphQLClient);
  } catch (e) {
    print('deleteTestUser failed');
    print(e);
    rethrow;
  }

  try {
    await deleteBookName(graphQLClient);
  } catch (e) {
    print('deleteBookName failed');
    print(e);
    rethrow;
  }

  try {
    await deleteBooksMessagesByName(graphQLClient);
  } catch (e) {
    print('deleteBooksMessagesByName failed');
    print(e);
    rethrow;
  }

  try {
    await deleteFamilyTestUsers(graphQLClient);
  } catch (e) {
    print('deleteFamilyTestUsers failed');
    print(e);
    rethrow;
  }

  try {
    await deleteNinth(graphQLClient);
  } catch (e) {
    print('deleteNinth failed');
    print(e);
    rethrow;
  }

  try {
    await deleteStoryReactions(graphQLClient);
  } catch (e) {
    print('deleteStoryReactions failed');
    print(e);
    rethrow;
  }
}

Future<void> deleteScenarioBook(GraphQLClient graphQLClient) async {
  try {
    await deleteTenth(graphQLClient);
  } catch (e) {
    print('deleteTenth failed');
    print(e);
    rethrow;
  }
}

Future<void> deleteTestOne(GraphQLClient graphQLClient) async {
  final Map<String, dynamic> fromUser = await graphql.getUserByName(
      graphQLClient, 'Test Name', 'bartonhammond@gmail.com');

  final Map<String, dynamic> toUser = await graphql.getUserByName(
      graphQLClient, 'Book Name', 'bartonhammond@gmail.com');

  if (fromUser != null && toUser != null) {
    await quitFriendships(graphQLClient, fromUser, toUser);
  }
}

Future<void> deleteTestUser(GraphQLClient graphQLClient) async {
  await graphql.deleteBookByName(
    graphQLClient,
    'Test Name',
  );
}

Future<void> _deleteBookByName(
  GraphQLClient graphQLClient,
  String bookName,
) async {
  await graphql.deleteBookByName(
    graphQLClient,
    bookName,
  );
}

Future<void> deleteBookName(
  GraphQLClient graphQLClient,
) async {
  await _deleteBookByName(graphQLClient, 'Book Name');
}

Future<void> deleteBooksMessagesByName(
  GraphQLClient graphQLClient,
) async {
  await graphql.deleteUserMessagesByName(
    graphQLClient,
    'Book Name',
  );
}

Future<void> deleteFamilyTestUsers(
  GraphQLClient graphQLClient,
) async {
  await _deleteBookByName(
    graphQLClient,
    'Family Story Provider',
  );
  await _deleteBookByName(
    graphQLClient,
    'Family Story Friend',
  );
}

Future<void> deleteNinth(
  GraphQLClient graphQLClient,
) async {
  final Map<String, dynamic> bookAuthorNameUser = await graphql.getUserByName(
      graphQLClient, 'Book Author Name', 'bartonhammond@gmail.com');

  final Map<String, dynamic> basicNameUser = await graphql.getUserByName(
      graphQLClient, 'Basic User Name', 'bartonhammond@gmail.com');

  if (bookAuthorNameUser != null && basicNameUser != null) {
    await quitFriendships(
      graphQLClient,
      bookAuthorNameUser,
      basicNameUser,
    );
  }
  await _deleteBookByName(
    graphQLClient,
    'Something Name',
  );
  await _deleteBookByName(
    graphQLClient,
    'Book Author Name',
  );
  await _deleteBookByName(
    graphQLClient,
    'Basic User Name',
  );
}

Future<void> deleteTenth(
  GraphQLClient graphQLClient,
) async {
  await graphql.deleteBookByName(
    graphQLClient,
    'Album Maker',
  );
  await graphql.deleteBookByName(
    graphQLClient,
    'Album Name',
  );
  await graphql.deleteBookByName(
    graphQLClient,
    'Friend To Album',
  );
  await graphql.deleteBookByName(
    graphQLClient,
    'Another',
  );
}

Future<void> deleteStoryReactions(GraphQLClient graphQLClient) async {
  final StoryUser storyUser = StoryUser();
  final StoryOriginalUser storyOriginalUser = StoryOriginalUser();
  final StoryComments storyComments = StoryComments();
  final StoryReactions storyReactions = StoryReactions(useFilter: true);
  final StoryTags storyTags = StoryTags();

  final StoryQl storyQl = StoryQl(
      core: true,
      storyUser: storyUser,
      storyOriginalUser: storyOriginalUser,
      storyComments: storyComments,
      storyReactions: storyReactions,
      storyTags: storyTags);

  final StorySearch storySearch = StorySearch.init(
    graphQLClient,
    storyQl,
    'bartonhammond@gmail.com',
  );
  final Map searchValues = <String, dynamic>{
    'currentUserEmail': 'bartonhammond@gmail.com',
    'limit': '1',
    'cursor': '2022-01-01'
  };
  final List stories = await storySearch.getList(searchValues);

  if (stories.isEmpty) {
    return;
  }
  await graphql.deleteUserReactionToStory(
    graphQLClient,
    'bartonhammond@gmail.com',
    stories[0]['id'],
  );
  final Map<String, dynamic> testNameUser = await graphql.getUserByName(
      graphQLClient, 'Test Name', 'bartonhammond@gmail.com');

  final Map<String, dynamic> bartonNameUser = await graphql.getUserByName(
      graphQLClient, 'Barton Hammond', 'bartonhammond@gmail.com');

  if (testNameUser != null && bartonNameUser != null) {
    await quitFriendships(
      graphQLClient,
      testNameUser,
      bartonNameUser,
    );
  }
  if (testNameUser != null) {
    for (Map message in testNameUser['messagesReceived']) {
      await graphql.deleteMessage(graphQLClient, message['id']);
    }
  }
  for (Map message in bartonNameUser['messagesReceived']) {
    await graphql.deleteMessage(graphQLClient, message['id']);
  }
  return;
}

Future<void> quitFriendships(
  GraphQLClient graphQLClient,
  Map<String, dynamic> fromUser,
  Map<String, dynamic> toUser,
) async {
  printJson('quitFriendships.fromUser', fromUser);
  printJson('quitFriendships.toUser', toUser);
  final UserFriends userFriends = UserFriends();

  final UserQl userQL = UserQl(
    userFriends: userFriends,
  );
  final UserSearch userSearch = UserSearch.init(
    graphQLClient,
    userQL,
    toUser['email'],
  );

  userSearch.setQueryName('getUserByEmail');
  userSearch.setVariables(<String, dynamic>{
    'currentUserEmail': 'String!',
  });

  final Map user = await userSearch.getItem(<String, dynamic>{
    'currentUserEmail': fromUser['email'],
  });
  printJson('quitFriendships.user', user);
  for (var friend in user['friendsTo']) {
    if (friend['receiver']['email'] == toUser['email']) {
      printJson('loop.receiver', friend);
      try {
        await graphql.quitFriendship(
          graphQLClient,
          friendId: friend['id'],
          fromUserId: fromUser['id'],
          toUserId: toUser['id'],
        );
      } catch (e) {
        print('quitFriendship1 failed');
        print(e);
        rethrow;
      }
      break;
    }
  }
  for (var friend in user['friendsFrom']) {
    if (friend['sender']['email'] == toUser['email']) {
      printJson('loop.sender', friend);
      try {
        await graphql.quitFriendship(
          graphQLClient,
          friendId: friend['id'],
          toUserId: fromUser['id'],
          fromUserId: toUser['id'],
        );
      } catch (e) {
        print('quitFriendship2 failed');
        print(e);
        rethrow;
      }
      break;
    }
  }
}
