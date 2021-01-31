enum GraphQLClientType {
  FileServer,
  Mp3Server,
  ApolloServer,
  ImageServer,
}

enum TabItem {
  stories,
  friends,
  messages,
  profile,
  newStory,
}

enum TypeUser {
  all,
  family,
  friends,
  users,
  books,
  me,
}

enum TypeSearch {
  date,
}

enum TypeStoriesView {
  allFriends,
  oneFriend,
  me,
}
final List reactionTypes = <String>[
  'LIKE',
  'HAHA',
  'JOY',
  'WOW',
  'SAD',
  'LOVE'
];
enum ReactionType {
  LIKE,
  HAHA,
  JOY,
  WOW,
  SAD,
  LOVE,
}
final List storyTypes = <String>[
  'FRIENDS',
  'FAMILY',
];
//What types can a story be?
enum StoryType {
  FRIENDS,
  FAMILY,
}

enum StoryFeedType {
  ALL,
  FRIENDS,
  FAMILY,
  ME,
}

final List messageTypes = <String>[
  'all',
  'message',
  'comment',
  'friend-request',
  'attention',
];
enum MessageType {
  ALL,
  MESSAGE,
  COMMENT,
  FRIEND_REQUEST,
  ATTENTION,
}
