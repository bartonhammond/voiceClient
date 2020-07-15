const String uploadFile = r'''
mutation($file: Upload!) {
  upload(file: $file)
}
''';

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

const String mergeUserFriends = r'''
  mutation mergeUserFriends($id: ID!, $from: ID!, $to: ID!, $created: String!) {
  MergeUserFriends(
    from: { id: $from }
    to: { id: $to }
    data: { id: $id, created: { formatted: $created } }
  ) {
    id
    from {
      email
    }
    to {
      email
    }
  }
}
''';
const String userActivities = r'''
query getUserActivities ($email: String!, $first: Int!, $offset: Int!) {
 User(email: $email) {
  id
  email
  activities(
    first: $first
    offset: $offset
  ) {
      id
      image
      audio
      created {
        formatted
      }
      user {
        email
      }
    }
  }
}
''';
