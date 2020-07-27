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
    home
    birth
    image
  }
}
''';
const String getUserById = r'''
query getUserByEmail($id: ID!) {
  User(id: $id) {
    id
    name
    email
    home
    birth
    image
  }
}
''';
const String getStoryById = r'''
query getStoryById($id: ID!) {
  Story(id: $id) {
    id
    image
    audio
    user {
      name
      home
      image
      birth
      id
    }
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

const String removeUserFriends = r'''
  mutation removeUserFriends($from: ID!, $to: ID!) {
  RemoveUserFriends(
    from: { id: $from }
    to: { id: $to }
  ) {
    from {
      id
    }
    to {
      id
    }
  }
}
''';
const String addUserMessage = r'''
mutation addUserMessage($from: $ID!, $to: $ID!, $id: String!, $created: String!, $type: String!, $text: String!, $status: String!){
  AddUserMessages(
	from: {
    id: $from
  }
  to: {
    id: $to
  }
  data: {
    id: id
    created: {
      formatted: $created
    }
    status: $status
    type: $type
    text: $text
  }
  ){
    from {
      id
      name
      email
    }
    to {
      id
      name
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
  name
  home
  image
  birth
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
        name
        home
        birth
        image
      }
    }
  }
}
''';
const String userStories = r'''
query getUserStories ($email: String!, $first: Int!, $offset: Int!) {
 User(email: $email) {
  id
  email
  home
  birth
  image
  stories(
    first: $first
    offset: $offset
  ) {
      id
      image
      audio
      created {
        formatted
      }
    }
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
const String getUserMessages = r'''
query getUserMessages($email: String!, $status: String!) {
  User(email: $email)  {
    id
    messages {  
      from (
        filter: {
          status: $status
        }
      ) 
      {
        User {
          id
          name
          email
          home
          birth
          image
        }
        text
        type
        status
        created {
          formatted
        }
      }
    }
  } 
}

''';
