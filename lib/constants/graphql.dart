const String uploadFile = r'''
mutation($file: Upload!) {
  uploadFile(file: $file)
}
''';

const String _user_ = r'''
 {
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
  
    messagesReceived {
     	id
      type
      created {
        formatted
      }
      status
      key
      from {
        id
        email
      }
    }
    messagesSent {
      id
      type
      created {
        formatted
      }
      status
      key
      to {
        id
        email
      }
    }
    messagesTopic {
      id
      type
      created {
        formatted
      }
      status
      key
      from {
        id
        email
      }
    }
    banned {
      from(filter: { User: { email: "_currentUserEmail_" } } ) {
        id
        User {
          id
          name
          email
        }
      }
    }
    friends {
      to (filter: { User: { email: "_currentUserEmail_" } } ){
        id
        isFamily
        User {
          email
        }
      }
    }  
    bookAuthor {
      id
      email
      name
      banned {
        from(filter: { User: { email: "_currentUserEmail_" } } )  {
          id
          User {
            id
            name
            email
          }
        }
      }
      friends {
        to(filter: { User: { email: "_currentUserEmail_" } }) {
          id
          isFamily
          User {
            email
          }
        }
      }
    }    
  }
''';

const _story_ = r'''
{
    __typename
    id
    image
    audio
    type
    created {
      formatted
    }
    updated {
      formatted
    }
    reactions(filter: { from: { email: "_currentUserEmail_"	} } ) {
      id
      type
    }
    user ''' +
    _user_ +
    r'''
    originalUser ''' +
    _user_ +
    r'''
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
    totalReactions
    totalLikes
    totalWows
    totalJoys
    totalHahas
    totalSads
    totalLoves
    tags {
      id
      created {
        formatted
      }
      user {
        id
        name
        email
      }
    }
  }

''';

const String getUserByEmailQL = r'''
query getUserByEmail($currentUserEmail: String!) {
  getUserByEmail(currentUserEmail: $currentUserEmail)''' +
    _user_ +
    '''
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
mutation createStory($id: ID!, $image: String!, $audio: String!, $created: String!, $updated: String!, $type: StoryType!) {
CreateStory(
    id: $id
    image: $image
    audio: $audio
    type: $type
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

const String addStoryOriginalUserQL = r'''
mutation addStoryOriginalUser($from: _UserInput!, $to: _StoryInput!) {
AddStoryOriginalUser(
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

const String removeUserStories = r'''
mutation removeStoryUser($from: _UserInput!, $to: _StoryInput!) {
RemoveStoryUser(
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

const String removeUserFriendsFromQL = r'''
  mutation removeUserFriendsFrom($fromFriendInput: ID!, $toUserInput: ID!) {
  RemoveUserFriendsFrom(
    from: { id: $fromFriendInput }
    to: { id: $toUserInput }
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

const String removeUserFriendsToQL = r'''
  mutation removeUserFriendsTo($fromUserInput: ID!, $toFriendInput: ID!) {
  RemoveUserFriendsTo(
    from: { id: $fromUserInput }
    to: { id: $toFriendInput }
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

const String getUserFriendsStoriesQL = r'''
query getUserFriendsStories($currentUserEmail: String!, $limit: String!, $cursor: String!) {
userFriendsStories(
  		currentUserEmail: $currentUserEmail
			limit: $limit
  		cursor: $cursor
		)''' +
    _story_ +
    '''      
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

const String deleteMessageQL = r'''
mutation deleteMessage($id: String!) {
  deleteMessage(id: $id)
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

const String createTagQL = r'''
mutation createTag($tagId: ID!, $created: String!, ) {
  CreateTag(
    id: $tagId
    created: { 
      formatted: $created 
      }
  ) {
    __typename
    id
  }
}
''';

const String addTagStoryQL = r'''
mutation addTagStory($storyId: ID!, $tagId: ID!) {
  AddTagStory(
    from: {
      id: $storyId,
    }
    to: {
      id: $tagId
    }
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

const String addTagUserQL = r'''
mutation addTagUser($userId: ID!, $tagId: ID!) {
  AddTagUser(
    from: {
      id: $userId
    }
    to: {
      id: $tagId
    }
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

const String deleteBookByNameQL = r'''
mutation deleteBookByName($name: String!) {
  deleteBookByName(name: $name)
}
''';

const String deleteUserMessagesByNameQL = r'''
mutation deleteUserMessagesByName($name: String!) {
  deleteUserMessagesByName(name: $name)
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
