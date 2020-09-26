const String uploadFile = r'''
mutation($file: Upload!) {
  uploadFile(file: $file)
}
''';

const String getUserByEmail = r'''
query getUserByEmail($email: String!) {
  User(email: $email) {
    __typename
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
    __typename
    id
    name
    email
    home
    birth
    image
  }
}
''';
const String getStoryByIdQL = r'''
query getStoryById($id: ID!) {
  Story(id: $id) {
    __typename
    id
    image
    audio
    created {
      formatted
    }
    updated {
      formatted
    }
    user {
      email
      name
      home
      image
      birth
      id
    }
    hashtags {
      tag
    }
    comments {
      id
      audio
      from {
        id
        name
        email
      }
      created {
        formatted
      }
      status
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
    created: { 
      formatted: $created 
    }
  ) {
    __typename
    id
    name
  }
}
''';

const String createStory = r'''
mutation createStory($id: ID!, $image: String!, $audio: String!, $created: String!, $updated: String!) {
CreateStory(
    id: $id
    image: $image
    audio: $audio
    created: {
      formatted: $created
    } 
    updated: {
      formatted: $updated  
    }
  ) {
    __typename
    id
    image 
    audio
    created { 
      formatted
    }
    updated { 
      formatted
    }
  }
}
''';

const String updateStoryQL = r'''
mutation updateStory($id: ID!, $image: String!, $audio: String!, $created: String!, $updated: String!) {
UpdateStory(
  id: $id
  image: $image
  audio: $audio
  created: {formatted: $created}
  updated: {formatted: $updated}
) {
   __typename
    id
    image 
    audio
    created { 
      formatted
    }
    updated { 
      formatted
    }
  } 
}
''';

const String deleteStoryQL = r'''
mutation deleteStory($id: ID!) {
DeleteStory(
  id: $id
) {
   __typename
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
    __typename
    from {
      id
    }
    to {
      id
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
      __typename
      id
      image
      audio
      created {
        formatted
      }
      updated { 
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

const String getUserStories = r'''
query getUserStories ($email: String!, $limit: String!, $cursor: String!) {
 userStories(
  		email: $email 
			limit: $limit
  		cursor: $cursor
		){
    __typename
    id
    image
    audio
    created {
      formatted
    }
    updated {
      formatted
    }
    user {
      email
      name
      home
      birth
      image
    }
    hashtags{
        tag
    }
    comments {
      id
      audio
      created {
        formatted
      }
      from {
        id
        email
        name
      }
      status
    }
  }
}
''';

const String getFriendsOfMine = r'''
query getFriendsOfMine ($email: String!) {
  friends(email: $email){
    __typename
    id
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
    __typename
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
query userSearchFriends($searchString: String!, $email: String!, $skip: String!, $limit: String! ) {
  userSearchFriends(searchString: $searchString, email: $email, skip: $skip, limit: $limit) {
    __typename
    id
    name
    email
    home
    birth
    image
    created {
      formatted
    }
  }
}
''';

const String userSearchNotFriends = r'''
query userSearchNotFriends($searchString: String!, $email: String!, $skip: String!, $limit: String!) {
  userSearchNotFriends(searchString: $searchString, email: $email, skip: $skip, limit: $limit) {
    __typename
    id
    name
    email
    home
    birth
    image
    created {
      formatted
    }
  }
}
''';

const String userSearchMeQL = r'''
query userSearchMe($email: String!) {
  User(email: $email) {
    __typename
    id
    name
    email
    home
    birth
    image
    created {
      formatted
    }
  }
}
''';

const String addUserMessage = r'''
mutation addUserMessage($from: ID!, $to: ID!, $id: ID!, $created: String!, $type: String!, $text: String!, $status: String!, $key1: String!){
  AddUserMessages(
	from: {
    id: $from
  }
  to: {
    id: $to
  }
  data: {
    id: $id
    created: {
      formatted: $created
    }
    status: $status
    type: $type
    text: $text
    key1: $key1
  }
  ){
    __typename
    id
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

const String updateUserMessage = r'''
mutation updateUserMessage($from: ID!, $to: ID!, $resolved: String!, $status: String!, $id: ID!, $created: String!, $text: String!, $type: String!){
  UpdateUserMessages(
	from: {
    id: $from
  }
  to: {
    id: $to
  }
  data: {
    id: $id
    created: {
      formatted: $created
    }
    resolved: {
      formatted: $resolved
    }
    status: $status
    text: $text
    type: $type
  }
  ){
    __typename
    id
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

const String getUserMessagesQL = r'''
query getUserMessages($email: String!, $status: String!) {
  User(email: $email)  {
    __typename
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
        id
        text
        type
        status
        created {
          formatted
        }
        key1
      }
    }
  } 
}
''';

const String getAllNewFriendRequestsToMe = r'''
query getAllNewFriendRequests($email: String) {
User(email: $email) {
    __typename
    id
    messages {
      from (filter: {
        type: "friend-request"
        status: "new"
      })
      
      {
        id
        type
        status
        resolved{
          formatted
        }
        created {
          formatted
        }
        User {
          id
          name
          email
        }
      } 
      }
    }
  }
''';

const String getAllMyFriendRequests = r'''
query getAllFriendRequests($email: String) {
User(email: $email) {
    __typename
    id
    messages {
      to (filter: {
        type: "friend-request"          
      })
      
      {
        __typename
        id
        type
        status
        resolved{
          formatted
        }
        created {
          formatted
        }
        User {
          id
          name
          email
        }
      } 
      }
    }
  }
''';

const String newMessagesCount = r'''
query newMessagesCount($email: String!) {
  newMessagesCount(email: $email) {
    __typename
    count
  }
}
''';

const String getUserFriendsStories = r'''
query getUserFriendsStories($email: String!, $limit: String!, $cursor: String!) {
userFriendsStories(
  		email: $email 
			limit: $limit
  		cursor: $cursor
		) {
    __typename
    id
    image
    audio
    created {
      formatted
    }
    updated {
      formatted
    }
    user {
      email
      name
      home
      birth
      image
    }
    hashtags{
        tag
    }
    comments {
      id
      audio
      created {
        formatted
      }
      status
      from {
        id
        email
        name
      }
    }
  }
}
''';

const String updateUser = r'''
mutation updateUser($id: ID!, $name: String, $home: String, $updated: String, $image: String, $birth: Int ){
UpdateUser(
  id: $id
  name: $name
  home: $home
  updated: {formatted: $updated}
  image: $image
  birth: $birth
) {
    id
    name
    email
    created {
      formatted
    }
    home
    image
    birth
    updated {
      formatted
    }
  }
}
''';

const String createCommentQL = r'''
mutation createComment($commentId: ID!, $storyId: ID!, $audio: String!, $status: String!, $created: String!, ) {
  CreateComment(
    id: $commentId
    story: $storyId
    audio: $audio
    status: $status
    created: { 
      formatted: $created 
      }
  ) {
    __typename
    id
    story
    audio
    status
    created {
      formatted
    }
  }
}
''';

const String updateCommentQL = r'''
mutation updateComment($commentId: ID!, $status: String!, $updated: String!, ) {
  UpdateComment(
    id: $commentId
    status: $status
    updated: { 
      formatted: $updated 
      }
  ) {
    __typename
    id
    story
    audio
    status
    created {
      formatted
    }
  }
}
''';

const String removeStoryCommentQL = r'''
mutation removeStoryComments($storyId: ID!, $commentId: ID!, ) {
  RemoveStoryComments(
    from: {
      id: $storyId
    }
    to: {
      id: $commentId
    }
  ) {
    __typename
    from {
      id
    }
    to {
      id
    }
  }
 
}
''';

const String deleteCommentQL = r'''
mutation deleteComment($commentId: ID!, ) {
  DeleteComment(
    id: $commentId
  ) {
    __typename
    id
  }
}
''';

const String mergeCommentFromQL = r'''
mutation mergeCommentFrom($userId: ID!, $commentId: ID!) {
  MergeCommentFrom(
    from: {
      id: $userId,
    }
    to: {
      id: $commentId
    }
  ) {
    from {
      email
      name
      id
    }
    to {
      id
      audio
    }
    
  }
}
''';

const String addStoryCommentsQL = r'''
mutation addStoryComments($storyId: ID!, $commentId: ID!) {
  AddStoryComments(
    from: {
      id: $storyId
    }
    to: {
      id: $commentId
    }
  ) {
    from {
      id
      image
      audio
    }
    to {
			id
      audio
    }
  }
}
''';

const String addHashTagQL = r'''
mutation addHashTag($tag: String!) {
  CreateHashTag(
    tag: $tag
  ) {
    tag
  }
}
''';

const String addStoryHashtagsQL = r'''
mutation addStoryHashtags($id: ID!, $tag: String!) {
  AddStoryHashtags(
    from:  {
      id: $id
      }
    to: {
      tag: $tag
    }
  ) {
    from {
      id
    }
    to {
      tag
    }
  }
}
''';

const String removeStoryHashtagsQL = r'''
mutation removeStoryHashtags($id: ID!, $tag: String!) {
  RemoveStoryHashtags(
    from:  {
      id: $id
      }
    to: {
      tag: $tag
    }
  ) {
    from {
      id
    }
    to {
      tag
    }
  }
}
''';

const String userHashTagsCountQL = r'''
query userHashTagsCount($email: String!){
  userHashTagsCount(email: $email) {
    __typename
    hashtag
    count
  }
}
''';

const String getUserFriendsStoriesByHashtagQL = r'''
query userFriendsStoriesByHashtag($email: String!, $searchString: String!, $cursor: String!, $limit: String!){
  userFriendsStoriesByHashtag(
    email: $email
    searchString: $searchString
    cursor: $cursor
    limit: $limit
    ){
    __typename
    id
    image
    audio
    created {
      formatted
    }
    updated {
      formatted
    }
    user {
      email
      name
      home
      birth
      image
    }
    hashtags{
        tag
    }
    comments {
      id
      audio
      created {
        formatted
      }
      from {
        id
        email
        name
      }
      status
    }
  }
} 
''';

const String getUserStoriesByHashtagQL = r'''
query userStoriesByHashtag($email: String!, $searchString: String!, $cursor: String!, $limit: String!){
  userStoriesByHashtag(
    email: $email
    searchString: $searchString
    cursor: $cursor
    limit: $limit
    ){
    __typename
    id
    image
    audio
    created {
      formatted
    }
    updated {
      formatted
    }
    user {
      email
      name
      home
      birth
      image
    }
    hashtags{
        tag
    }
    comments {
      id
      audio
      created {
        formatted
      }
      from {
        id
        email
        name
      }
      status
    }
  }
} 
''';
