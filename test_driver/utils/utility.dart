import 'package:MyFamilyVoice/ql/story/story_comments.dart';
import 'package:MyFamilyVoice/ql/story/story_original_user.dart';
import 'package:MyFamilyVoice/ql/story/story_reactions.dart';
import 'package:MyFamilyVoice/ql/story/story_search.dart';
import 'package:MyFamilyVoice/ql/story/story_tags.dart';
import 'package:MyFamilyVoice/ql/story/story_user.dart';
import 'package:MyFamilyVoice/ql/story_ql.dart';
import 'package:graphql/client.dart';
import '../graphQL.dart' as graphql;

Future<void> deleteScenarioAllBasic(GraphQLClient graphQLClient) async {
  await deleteTestOne(graphQLClient);
  await deleteTestUser(graphQLClient);
  await deleteBookName(graphQLClient);
  await deleteBooksMessagesByName(graphQLClient);
  await deleteFamilyTestUsers(graphQLClient);
  await deleteNinth(graphQLClient);
  await deleteStoryReactions(graphQLClient);
}

Future<void> deleteScenarioBook(GraphQLClient graphQLClient) async {
  await deleteTenth(graphQLClient);
}

Future<void> deleteTestOne(GraphQLClient graphQLClient) async {
  Map<String, dynamic> result = await graphql.getUserByName(
      graphQLClient, 'Test Name', 'bartonhammond@gmail.com');
  if (result != null) {
    final String toId = result['id'];
    result = await graphql.getUserByName(
        graphQLClient, 'Book Name', 'bartonhammond@gmail.com');
    if (result != null) {
      final String fromId = result['id'];
      await graphql.quitFriendship(graphQLClient, toId, fromId);
    }
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
    await graphql.quitFriendship(
        graphQLClient, bookAuthorNameUser['id'], basicNameUser['id']);
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
    await graphql.quitFriendship(
        graphQLClient, testNameUser['id'], bartonNameUser['id']);
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
