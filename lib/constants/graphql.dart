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
mutation createUser($id: ID!, $email: String!, $name: String, $home: String, $birth: Int, $image: String, $created: String!, ) {
  CreateUser(
    id: $id
    name: $name
    email: $email
    home: $home
    image: $image
    birth: $birth
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
    image 
    audio
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
    email: $email
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
const String getStoryById = r'''
query getStoryById ($id: String!) {
 Story(id: $id) {
  id
  image
  audio
  }
}
''';

const String getFriendsOfMine = r'''
query getFriendsOfMine ($email: String!) {
  friends(email: $email){
    isFriend
		email
    name
    home
    image
    created{
      formatted
    }
  }
}
''';
const String userSearch = r'''
query userSearch($searchString: String!) {
  userSearch(searchString: $searchString) {
    id
    name
    email
    home
    birth
    image
  }
}
''';
const String userSearchFriends = r'''
query userSearchFriends($searchString: String!, $email: String!) {
  userSearchFriends(searchString: $searchString, email: $email) {
    id
    name
    email
    home
    birth
    image
  }
}
''';
const String userSearchNotFriends = r'''
query userSearchNotFriends($searchString: String!, $email: String!) {
  userSearchNotFriends(searchString: $searchString, email: $email) {
    id
    name
    email
    home
    birth
    image
  }
}
''';
