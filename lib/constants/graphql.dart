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
    bookAuthorEmail
    created{
      formatted
    }
    friends {
      from {
        isFamily
        User {
          email
        }
      }
    }
  }
''';

const String _friend_ = r'''
 {
    __typename
    id
    name
    email
    home
    image
    isBook
    bookAuthorEmail
    created {
      formatted
    }
    friends {
      from {
        isFamily
        User {
          email
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
    user {
      email
      name
      home
      image
      isBook
      bookAuthorEmail
      id
      friends {
        from {
          isFamily
          User {
            email
          }
        }
      }      
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
    reactions(filter: { from: { email: $email	} } ) {
      id
      type
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
query getUserByEmail($email: String!) {
  User(email: $email)''' +
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
    bookAuthorEmail
  }
}
''';

const String getUserByIdQL = r'''
query getUserById($id: ID!) {
User(id: $id)''' +
    _user_ +
    '''
}
''';

const String getStoryByIdQL = r'''
query getStoryById($id: ID!, $email: String!) {
Story(id: $id)''' +
    _story_ +
    '''
}
''';

const String getStoryReactionsByIdQL = r'''
query storyReactions($id: String!, $email: String!) {
storyReactions(
  email: $email, 
  id: $id
  orderBy: [
    type_asc
  ]
  ){
    id
    type
    created{
      formatted
    }
    userId
    email
    name
    home
    bookAuthorEmail
    image
    isBook
    friend
  }
}
''';

const String createUserQL = r'''
mutation createUser($id: ID!, $email: String!, $name: String, $home: String, $image: String, $created: String!, $isBook: Boolean!, $bookAuthorEmail: String!) {
  CreateUser(
    id: $id
    name: $name
    email: $email
    home: $home
    image: $image
    isBook: $isBook
    bookAuthorEmail: $bookAuthorEmail
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
    bookAuthorEmail
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
mutation updateStory($id: ID!, $image: String!, $audio: String!, $created: String!, $updated: String!, $type: StoryType!) {
UpdateStory(
  id: $id
  image: $image
  audio: $audio
  type: $type
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

const String mergeUserFriends = r'''
  mutation mergeUserFriends($id: ID!, $from: ID!, $to: ID!, $created: String!) {
  MergeUserFriends(
    from: { id: $from }
    to: { id: $to }
    data: { 
      id: $id, 
      created: { 
        formatted: $created 
      } 
      isFamily: false
    }
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
  isBook
  bookAuthorEmail
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
        image
        isBook
        bookAuthorEmail
      }
    }
  }
}
''';

const String getUserStoriesQL = r'''
query getUserStories ($email: String!, $currentUserEmail: String!, $limit: String!, $cursor: String!) {
 userStories(
  		email: $email 
      currentUserEmail: $currentUserEmail
			limit: $limit
  		cursor: $cursor
		)''' +
    _story_ +
    '''      
}
''';

const String getUserStoriesFriendsQL = r'''
query getUserStoriesFriends($email: String!, $limit: String!, $cursor: String!) {
 userStoriesFriends(
  		email: $email 
			limit: $limit
  		cursor: $cursor
		)''' +
    _story_ +
    '''
}
''';

const String getUserStoriesFamilyQL = r'''
query getUserStoriesFamily($email: String!, $currentUserEmail: String!, $limit: String!, $cursor: String!) {
 userStoriesFamily(
  		email: $email 
      currentUserEmail: $currentUserEmail
			limit: $limit
  		cursor: $cursor
		)''' +
    _story_ +
    '''      
}
''';

const String getUserStoriesGlobalQL = r'''
query getUserStoriesGlobal($email: String!, $limit: String!, $cursor: String!) {
 userStoriesGlobal(
  		email: $email 
			limit: $limit
  		cursor: $cursor
		)''' +
    _story_ +
    '''
}
''';

const String getUserStoriesMeQL = r'''
query getUserStoriesMe ($email: String!, $limit: String!, $cursor: String!) {
 userStoriesMe(
  		email: $email 
			limit: $limit
  		cursor: $cursor
		)''' +
    _story_ +
    '''      
}
''';

const String getUserStoriesMeFamilyQL = r'''
query getUserStoriesMeFamily ($email: String!, $limit: String!, $cursor: String!) {
 userStoriesMeFamily(
  		email: $email 
			limit: $limit
  		cursor: $cursor
		)''' +
    _story_ +
    '''      
}
''';

const String getFriendsOfMineQL = r'''
query getFriendsOfMine ($email: String!) {
  friendsOfMine(email: $email)
  ''' +
    _user_ +
    '''
}
''';

const String getBooksOfMineQL = r'''
query getBooksOfMine ($email: String!) {
  books(email: $email) ''' +
    _user_ +
    '''
}
''';

const String userSearchQL = r'''
query userSearch($searchString: String!, $skip: String!, $limit: String!) {
  userSearch(searchString: $searchString, skip: $skip, limit: $limit) ''' +
    _friend_ +
    '''
}
''';

const String userSearchFriendsQL = r'''
query userSearchFriends($searchString: String!, $email: String!, $skip: String!, $limit: String! ) {
   userSearchFriends(searchString: $searchString, email: $email, skip: $skip, limit: $limit)''' +
    _friend_ +
    '''
}
''';
const String userSearchFriendsBooksQL = r'''
query userSearchFriendsBooks($searchString: String!, $email: String!, $skip: String!, $limit: String! ) {
   userSearchFriendsBooks(searchString: $searchString, email: $email, skip: $skip, limit: $limit)''' +
    _friend_ +
    '''
}
''';

const String userSearchFamilyQL = r'''
query userSearchFamily($searchString: String!, $email: String!, $skip: String!, $limit: String! ) {
   userSearchFamily(searchString: $searchString, email: $email, skip: $skip, limit: $limit)''' +
    _friend_ +
    '''
}
''';

const String userSearchFamilyBooksQL = r'''
query userSearchFamily($searchString: String!, $email: String!, $skip: String!, $limit: String! ) {
   userSearchFamilyBooks(searchString: $searchString, email: $email, skip: $skip, limit: $limit)''' +
    _friend_ +
    '''
}
''';

const String userSearchBooksQL = r'''
query userSearchBooks($searchString: String!, $email: String!, $skip: String!, $limit: String! ) {
   userSearchBooks(searchString: $searchString, email: $email, skip: $skip, limit: $limit)''' +
    _friend_ +
    '''
}
''';

const String userSearchNotFriendsQL = r'''
query userSearchNotFriends($searchString: String!, $email: String!, $skip: String!, $limit: String!) {
  userSearchNotFriends(searchString: $searchString, email: $email, skip: $skip, limit: $limit)''' +
    _friend_ +
    '''  
}
''';

const String userSearchNotFriendsBooksQL = r'''
query userSearchNotFriendsBooks($searchString: String!, $email: String!, $skip: String!, $limit: String!) {
  userSearchNotFriendsBooks(searchString: $searchString, email: $email, skip: $skip, limit: $limit)''' +
    _friend_ +
    '''  
}
''';

const String userSearchMeQL = r'''
query userSearchMe($email: String!) {
  User(email: $email)''' +
    _friend_ +
    '''  
}
''';

const String addUserMessagesQL = r'''
mutation addUserMessages($from: ID!, $to: ID!, $id: ID!, $created: String!, $status: String!, $text: String!, $type: String!, $key1: String){
  AddUserMessages (
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
      text: $text
      type: $type  
      key1: $key1 
    }
  ) 
  {
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

const String updateUserMessageStatusByIdQL = r'''
mutation updateUserMessageStatusById($email: String!, $id: String! $status: String!, $resolved: String!){
  updateUserMessageStatusById(
    email: $email
    id: $id
    status: $status
    resolved: $resolved
  ){
    __typename
    messageId
    messageStatus
  }
}
''';
const String _message_ = r'''
 {
    __typename
    messageId
    messageType
    messageCreated {
      formatted
    }
    messageText
    messageKey1
    messageStatus
    userId
    userEmail
    userName
    userHome
    userImage
    userIsBook
    userBookAuthorEmail
  }
''';

const String getUserMessagesQL = r'''
query getUserMessages($email: String!, $status: String!, $cursor: String, $limit: String) {
  userMessages(email: $email, status: $status, cursor: $cursor, limit: $limit)''' +
    _message_ +
    '''  
}
''';

const String getUserMessagesByTypeQL = r'''
query getUserMessagesByType($email: String!, $status: String!, $cursor: String, $limit: String, $type: String) {
  userMessagesByType(email: $email, status: $status, cursor: $cursor, limit: $limit, type: $type)''' +
    _message_ +
    '''  
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

const String getUserFriendsStoriesQL = r'''
query getUserFriendsStories($email: String!, $limit: String!, $cursor: String!) {
userFriendsStories(
  		email: $email 
			limit: $limit
  		cursor: $cursor
		)''' +
    _story_ +
    '''      
}
''';

const String getUserFriendsStoriesFamilyQL = r'''
query getUserFriendsStoriesFamily($email: String!, $limit: String!, $cursor: String!) {
userFriendsStoriesFamily(
  		email: $email 
			limit: $limit
  		cursor: $cursor
		)''' +
    _story_ +
    '''      
}
''';

const String getUserFriendsStoriesFriendsQL = r'''
query getUserFriendsStoriesFriends($email: String!, $limit: String!, $cursor: String!) {
userFriendsStoriesFriends(
  		email: $email 
			limit: $limit
  		cursor: $cursor
		)''' +
    _story_ +
    '''      
}
  ''';

const String getUserFriendsStoriesGlobalQL = r'''
query getUserFriendsStoriesGlobal($email: String!, $limit: String!, $cursor: String!) {
userFriendsStoriesGlobal(
			limit: $limit
  		cursor: $cursor
		)''' +
    _story_ +
    '''      
}
  ''';

const String updateUserQL = r'''
mutation updateUser($id: ID!, $name: String!, $home: String!, $updated: String!, $image: String!, $isBook: Boolean!, $bookAuthorEmail: String!){
UpdateUser(
  id: $id
  name: $name
  home: $home
  updated: {formatted: $updated}
  image: $image
  isBook: $isBook
  bookAuthorEmail: $bookAuthorEmail
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
    bookAuthorEmail
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

const String createReactionQL = r'''
mutation CreateReaction($id: ID!, $storyId: ID!, $created: String!, $type: ReactionType!) {
  CreateReaction(
    id: $id
    story: $storyId
    created: {
      formatted: $created
    }
    type: $type
  ) {
    id
    type
    created {
      formatted
    }
  }
}
''';

const String addReactionFromQL = r'''
mutation AddReactionFrom($userId: ID!, $reactionId: ID!) {
  AddReactionFrom(
    from: {
      id: $userId
    }
    to: {
      id: $reactionId
    }
  ) {
    from {
      email
    }
    to {
        type
    }
    
  }
}
''';

const String addStoryReactionQL = r'''
mutation AddStoryReaction($storyId: ID!, $reactionId: ID!) {
  AddStoryReactions(
    from: {
      id: $storyId
    }
    to: {
      id: $reactionId
    }
  ) {
    from {
      id
    }
    to {
      type
    }
    
  }
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
mutation deleteMessage($storyId: String!) {
  deleteMessage(storyId: $storyId)
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
mutation createTag($tagId: ID!, $storyId: ID!, $created: String!, ) {
  CreateTag(
    id: $tagId
    story: $storyId
    created: { 
      formatted: $created 
      }
  ) {
    __typename
    id
    story
    created {
      formatted
    }
  }
}
''';

const String addStoryTagsQL = r'''
mutation addStoryTags($storyId: ID!, $tagId: ID!) {
  AddStoryTags(
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

const String addUserTagsQL = r'''
mutation addUserTags($userId: ID!, $tagId: ID!) {
  AddUserTags(
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
mutation deleteBook($id: String!) {
  deleteBook(id: $id)
}
''';
