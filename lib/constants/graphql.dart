const String getUserByEmail = r'''
query getUserByEmail($email: String!) {
  User(email: $email) {
    id
    name
    email
  }
}
''';

const String createUser = r'''
mutation createUser($id: ID!, $email: String!, $created: String!) {
  CreateUser(
    id: $id
    email: $email
    created: { formatted: $created }
  ) {
    id
    name
  }
}
''';

const String createStory = r'''
mutation createStory($id: ID!, $image: String!, $audio: String!, $created: String!) {
CreateStory(
    id: $id
    image: $image
    audio: $audio
    created: { formatted: $created }
  ) {
    id
  }
}
''';

const String mergeUserStories = r'''
mutation mergeStoryUser($from: _UserInput!, $to: _StoryInput!) {
MergeStoryUser(
    from: $from
    to: $to
  ) {
    from {
      email
    }
    to {
      audio
      image
    }
  }
}

''';
