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
  friends,
  users,
  me,
}

enum TypeSearch {
  date,
}

enum TypeStoriesView {
  allFriends,
  oneFriend,
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
  'GLOBAL',
  'FRIENDS',
  'FAMILY',
];
enum StoryType {
  GLOBAL,
  FRIENDS,
  FAMILY,
}
final List messageTypes = <String>[
  'all',
  'message',
  'comment',
  'friend-request'
];
enum MessageType {
  ALL,
  MESSAGE,
  COMMENT,
  FRIEND_REQUEST,
}
