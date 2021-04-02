const String uploadFile = r'''
mutation($file: Upload!) {
  uploadFile(file: $file)
}
''';

const String getUserByEmailForAuthQL = r'''
query getUserByEmail($email: String!) {
  User(email: $email) {
    __typename
    id
    name
    email
    home
    image
    isBook
    tokens
  }
}
''';

const String createUserQL = r'''
mutation createUser($id: ID!, $email: String!, $name: String, $home: String, $image: String, $created: String!, $isBook: Boolean!) {
  CreateUser(
    id: $id
    name: $name
    email: $email
    home: $home
    image: $image
    isBook: $isBook
    created: { 
      formatted: $created 
    }
  ) {
    __typename
    id
    name
    email
    home
    image
    isBook
    created {
      formatted
    }
  }
}
''';

const String createStory = r'''
mutation createStory(
  $storyId: ID!, 
  $image: String!, 
  $audio: String!, 
  $created: String!, 
  $updated: String!, 
  $type: StoryType!,
  $userId: ID!) {

CreateStory(
    id: $storyId
    image: $image
    audio: $audio
    type: $type
    created: {
      formatted: $created
    } 
    updated: {
      formatted: $updated  
    }
  ){
    id
  }
  MergeStoryUser(
    from: {
      id: $userId
    } 
    to: {
      id: $storyId
    }
  ) {
    from {
      id
    }
  }

}
''';

const String updateStoryQL = r'''
mutation updateStory($id: ID!, $image: String!, $audio: String!, $created: String!, $updated: String!, $type: StoryType!,) {
updateStory(
    id: $id
    image: $image
    audio: $audio
    type: $type
    created: $created
    updated: $updated
  ) {
    id
  }
}
  
''';

const String createMessageQL = r'''
mutation createMessage(
  $messageId: String!, 
  $created: String!, 
  $status: String!, 
  $type: String!, 
  $key: String,
  $fromUserId: String!,
  $toUserId: String!){
createMessage(
  messageId: $messageId
  created: $created 
  status: $status
  type: $type
  key: $key
  fromUserId: $fromUserId
  toUserId: $toUserId
) 
}
''';
const String createMessageWithBookQL = r'''
mutation createMessageWithBook(
  $messageId: String!, 
  $created: String!, 
  $status: String!, 
  $type: String!, 
  $key: String,
  $fromUserId: String!,
  $toUserId: String!
  $bookUserId: String!){
createMessageWithBook(
  messageId: $messageId
  created: $created 
  status: $status
  type: $type
  key: $key
  fromUserId: $fromUserId
  toUserId: $toUserId
  bookUserId: $bookUserId
) 
}
''';

const String updateUserMessageStatusByIdQL = r'''
mutation updateUserMessageStatusById($currentUserEmail: String!, $id: String! $status: String!, $resolved: String!){
  updateUserMessageStatusById(
    currentUserEmail: $currentUserEmail
    id: $id
    status: $status
    resolved: $resolved
  ){
    __typename
    id
    status
  }
}
''';

const String updateUserQL = r'''
mutation updateUser($id: ID!, $name: String!, $home: String!, $updated: String!, $image: String!, $isBook: Boolean!,){
UpdateUser(
  id: $id
  name: $name
  home: $home
  updated: {formatted: $updated}
  image: $image
  isBook: $isBook
) {
    id
    name
    email
    created {
      formatted
    }
    home
    image
    isBook
    updated {
      formatted
    }
  }
}
''';

const String createCommentQL = r'''
mutation createComment($commentId: String!, $audio: String!, $status: String!, 
                        $updated: String!, $userId: String! $storyId: String! ) {
  createComment(
    commentId: $commentId
    audio: $audio
    status: $status
    updated: $updated
    userId: $userId
    storyId: $storyId
  ) 
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

const String createReactionQL = r'''
mutation createReaction(
    $reactionId: String!, 
    $created: String!, 
    $type: String!,
    $storyId: String!,
    $userId: String!) {
  createReaction(
    reactionId: $reactionId
    created: $created
    type: $type
    storyId: $storyId
    userId: $userId
  ) 
}
''';
const String changeReactionQL = r'''
mutation createReaction(
    $originalReactionId: String!,
    $reactionId: String!, 
    $created: String!, 
    $type: String!,
    $storyId: String!,
    $userId: String!) {
  changeReaction(
    originalReactionId: $originalReactionId
    reactionId: $reactionId
    created: $created
    type: $type
    storyId: $storyId
    userId: $userId
  ) 
}
''';

const String deleteUserReactionToStoryQL = r'''
mutation deleteUserReactionToStory($storyId: String!, $email: String!) {
  deleteUserReactionToStory(storyId: $storyId, email: $email){
    id
  }
}
''';

const String deleteStoryQL = r'''
mutation deleteStory($storyId: String!) {
  deleteStory(storyId: $storyId)
}
''';

const String updateUserIsFamilyQL = r'''
mutation updateUserIsFamily($emailFrom: String!, $emailTo: String!, $isFamily: Boolean!) {
  updateUserIsFamily(emailFrom: $emailFrom, emailTo: $emailTo, isFamily: $isFamily){
    id
    isFamily
  }
}
''';

const String deleteStoriesTagsQL = r'''
mutation deleteStoryTags($storyId: String!) {
  deleteStoryTags(storyId: $storyId){
    id
  }
}
''';

const String deleteBookQL = r'''
mutation deleteBook($email: String!) {
  deleteBook(email: $email)
}
''';

const String getUserByNameQL = r'''
query getUserByName($name: String!, $currentUserEmail: String!) {
getUserByName(name: $name, currentUserEmail: $currentUserEmail) {
    __typename
    id
    name
    email
    home
    image
    isBook   
    created{
      formatted
    }
  }
}
''';

const String deleteBanQL = r'''
mutation deleteBan($id: String!) {
deleteBan(
  id: $id
  )
}
''';

const String addUserBookAuthorQL = r'''
mutation addUserBookAuthor($from: ID!, $to: ID!, ){
  AddUserBookAuthor (
    from: {
      id: $from
    }
    to: {
      id: $to
    }
  ) 
  {
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

const String addUserFriendsQL = r'''
mutation createFriends(
  $friendId1: ID!, 
  $friendId2: ID!, 
  $created: String!, 
  $userId1: ID! 
  $isFamily1: Boolean!, 
  $userId2: ID!, 
  $isFamily2: Boolean!) {
    createFriends(
      friendId1: $friendId1,
      friendId2: $friendId2,
      created: $created,
      userId1: $userId1,
      isFamily1: $isFamily1,
      userId2: $userId2,
      isFamily2: $isFamily2
    )
  }
''';

const String deleteFriendsQL = r'''
mutation deleteFriends(
  $friendId1: String!, 
  $friendId2: String!) {
    deleteFriends(
      friendId1: $friendId1,
      friendId2: $friendId2
    )
  }
''';

const String createBanQL = r'''
mutation createBan(
  $banId: String!, 
  $bannerId: String!, 
  $bannedId: String!, 
  $created: String!) {
    createBan(
      banId: $banId,
      bannerId: $bannerId,
      bannedId: $bannedId,
      created: $created
    )
  }
''';
const String changeStoryUserQL = r'''
mutation changeStoryUser(
  $originalUserId: String!,
  $storyId: String!,
  $newUserId: String!) {
    changeStoryUser(
      originalUserId: $originalUserId,
      storyId: $storyId,
      newUserId: $newUserId
    )
  }
''';

const String changeStoryUserAndSaveOriginalUserQL = r'''
mutation changeStoryUserAndSaveOriginalUser(
  $originalUserId: ID!,
  $storyId: ID!,
  $newUserId: ID!) {
  
  AddStoryOriginalUser(
    from: {
      id: $originalUserId
    }
    to: {
      id: $storyId
    }
  ) {
    from {
      id
    }
  }

  RemoveStoryUser(
    from: {
      id: $originalUserId
    }
    to: {
      id: $storyId
    }
  ) {
   from {
     id
   }
  }

  MergeStoryUser(
    from: {
      id: $newUserId
    }
    to: {
      id: $storyId
    }
  ) {
    from {
      id
    }
  }
}
''';

const String updateUserTokenQL = r'''
mutation updateUserToken(
  $currentUserEmail: String!, 
  $tokens: String!) {
    updateUserToken(
      currentUserEmail: $currentUserEmail,
      tokens: $tokens
    ){
      id
    }
  }
''';

const String sendNotificationToDeviceQL = r'''
mutation sendNotificationToDevice(
  $token: String!, 
  $type: String!) {
    sendNotificationToDevice(
      token: $token,
      type: $type
    )
  }
''';
