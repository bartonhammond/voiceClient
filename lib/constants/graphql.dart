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
    messagesReceived(filter: {status: "new" }) {
     	id
      type
      created {
        formatted
      }
      fromEmail
      toEmail
      status
      key1
      key2
      from {
        id
        email
      }
    }
    messagesSent(filter: {status: "new" }) {
      id
      type
      created {
        formatted
      }
      fromEmail
      toEmail
      status
      key1
      key2
      from {
        id
        email
      }
    }
    banned {
      from(filter: { User: { email_in: [$currentUserEmail] } }) {
        id
        User {
          id
          name
          email
        }
      }
    }
    friends {
      to(filter: { User: { email_in: [$currentUserEmail] } }) {
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
        from(filter: { User: { email_in: [$currentUserEmail] } }) {
          id
          User {
            id
            name
            email
          }
        }
      }
      friends {
        to(filter: { User: { email_in: [$currentUserEmail] } }) {
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
    reactions(filter: { from: { email: $currentUserEmail	} } ) {
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

const String getUserByIdQL = r'''
query getUserById($id: ID!) {
User(id: $id)''' +
    _user_ +
    '''
}
''';

const String getStoryByIdQL = r'''
query getStoryById($id: String!, $currentUserEmail: String!) {
getStoryById(
  id: $id, 
  currentUserEmail: $currentUserEmail)''' +
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
    image
    isBook
    friend
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
      }
    }
  }
}
''';

const String getUserStoriesQL = r'''
query getUserStories ($currentUserEmail: String!, $limit: String!, $cursor: String!) {
 userStories(
      currentUserEmail: $currentUserEmail
			limit: $limit
  		cursor: $cursor
		)''' +
    _story_ +
    '''      
}
''';

const String getUserStoriesFriendsQL = r'''
query getUserStoriesFriends($currentUserEmail: String!, $limit: String!, $cursor: String!) {
 userStoriesFriends(
  		currentUserEmail: $currentUserEmail
			limit: $limit
  		cursor: $cursor
		)''' +
    _story_ +
    '''
}
''';

const String getUserStoriesFamilyQL = r'''
query getUserStoriesFamily($currentUserEmail: String!, $limit: String!, $cursor: String!) {
 userStoriesFamily(
      currentUserEmail: $currentUserEmail
			limit: $limit
  		cursor: $cursor
		)''' +
    _story_ +
    '''      
}
''';

const String getUserStoriesMeQL = r'''
query getUserStoriesMe ($currentUserEmail: String!, $limit: String!, $cursor: String!) {
 userStoriesMe(
  		currentUserEmail: $currentUserEmail 
			limit: $limit
  		cursor: $cursor
		)''' +
    _story_ +
    '''      
}
''';

const String getUserStoriesMeFamilyQL = r'''
query getUserStoriesMeFamily ($currentUserEmail: String!, $limit: String!, $cursor: String!) {
 userStoriesMeFamily(
  		currentUserEmail: $currentUserEmail 
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
query userSearch($currentUserEmail: String!, $searchString: String!, $skip: String!, $limit: String!) {
  userSearch(currentUserEmail: $currentUserEmail, searchString: $searchString, skip: $skip, limit: $limit) ''' +
    _user_ +
    '''
}
''';

const String userSearchFriendsQL = r'''
query userSearchFriends($searchString: String!, $currentUserEmail: String!, $skip: String!, $limit: String!) {
   userSearchFriends(searchString: $searchString, currentUserEmail: $currentUserEmail, skip: $skip, limit: $limit)''' +
    _user_ +
    '''
}
''';
const String userSearchFriendsBooksQL = r'''
query userSearchFriendsBooks($searchString: String!, $currentUserEmail: String!, $skip: String!, $limit: String!) {
   userSearchFriendsBooks(searchString: $searchString, currentUserEmail: $currentUserEmail, skip: $skip, limit: $limit)''' +
    _user_ +
    '''
}
''';

const String userSearchFamilyQL = r'''
query userSearchFamily($searchString: String!, $currentUserEmail: String!, $skip: String!, $limit: String!) {
   userSearchFamily(searchString: $searchString, currentUserEmail: $currentUserEmail, skip: $skip, limit: $limit)''' +
    _user_ +
    '''
}
''';

const String userSearchFamilyBooksQL = r'''
query userSearchFamily($searchString: String!, $currentUserEmail: String!, $skip: String!, $limit: String!) {
   userSearchFamilyBooks(searchString: $searchString, currentUserEmail: $currentUserEmail, skip: $skip, limit: $limit)''' +
    _user_ +
    '''
}
''';

const String userSearchBooksQL = r'''
query userSearchBooks($searchString: String!, $currentUserEmail: String!, $skip: String!, $limit: String!) {
   userSearchBooks(searchString: $searchString, currentUserEmail: $currentUserEmail, skip: $skip, limit: $limit)''' +
    _user_ +
    '''
}
''';

const String userSearchNotFriendsQL = r'''
query userSearchNotFriends($searchString: String!, $currentUserEmail: String!, $skip: String!, $limit: String!) {
  userSearchNotFriends(searchString: $searchString, currentUserEmail: $currentUserEmail, skip: $skip, limit: $limit)''' +
    _user_ +
    '''  
}
''';

const String userSearchNotFriendsBooksQL = r'''
query userSearchNotFriendsBooks($searchString: String!, $currentUserEmail: String!, $skip: String!, $limit: String!) {
  userSearchNotFriendsBooks(searchString: $searchString, currentUserEmail: $currentUserEmail, skip: $skip, limit: $limit)''' +
    _user_ +
    '''  
}
''';

const String userSearchMeQL = r'''
query userSearchMe($email: String!) {
  User(email: $email)''' +
    _user_ +
    '''  
}
''';

const String createMessageQL = r'''
mutation createMessage($id: ID!, $created: String!, $status: String!, $type: String!, $key1: String, $key2: String, $toEmail: String!, $fromEmail: String!){
CreateMessage(
  id: $id
  created: { 
      formatted: $created 
  }
  status: $status
  type: $type
  key1: $key1
  key2: $key2
  toEmail: $toEmail
  fromEmail: $fromEmail
) {
  __typename
    id
}
   
}
''';

const String addUserMessagesSentQL = r'''
mutation addUseMessagesSent($from: _UserInput!, $to: _MessageInput! ){
AddUserMessagesSent(
  from: $from
  to: $to
) {
    from {
      id
    }
    to  {
      id
    }
  }
}
''';

const String addUserMessagesReceivedQL = r'''
mutation addUserMessagesReceived($to: _UserInput!, $from: _MessageInput! ) {
AddUserMessagesReceived(
  from: $from
  to: $to
) {
    from {
      id
    }
    to  {
      id
    }
  }
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
const String _message_ = r'''
 {
    __typename
    id
    type
    status
    key1
    key2
    created {
      formatted
    }
    fromEmail
    toEmail
    from ''' +
    _user_ +
    r'''
    to ''' +
    _user_ +
    r'''    
  }
''';

const String getUserMessagesReceivedQL = r'''
query getUserMessagesReceived($currentUserEmail: String!, $status: String!, $cursor: String!, $limit: String!) {
  userMessagesReceived(currentUserEmail: $currentUserEmail, status: $status, cursor: $cursor, limit: $limit)
    {
    __typename
    id
    type
    status
    key1
    key2
    created {
      formatted
    }
    from ''' +
    _user_ +
    r'''    
  }
}
''';

const String getUserMessagesSentQL = r'''
query getUserMessagesSent($currentUserEmail: String!, $status: String!, $cursor: String!, $limit: String!) {
  userMessagesSent(currentUserEmail: $currentUserEmail, status: $status, cursor: $cursor, limit: $limit)
    {
    __typename
    id
    type
    status
    key1
    key2
    created {
      formatted
    }
    to ''' +
    _user_ +
    r'''    
  }
}
''';

const String getUserMessagesByTypeQL = r'''
query getUserMessagesByType($currentUserEmail: String!, $status: String!, $cursor: String!, $limit: String!, $type: String!) {
  userMessagesByType(currentUserEmail: $currentUserEmail, status: $status, cursor: $cursor, limit: $limit, type: $type)''' +
    _message_ +
    '''  
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

const String getUserFriendsStoriesFamilyQL = r'''
query getUserFriendsStoriesFamily($currentUserEmail: String!, $limit: String!, $cursor: String!) {
userFriendsStoriesFamily(
  		currentUserEmail: $currentUserEmail 
			limit: $limit
  		cursor: $cursor
		)''' +
    _story_ +
    '''      
}
''';

const String getUserFriendsStoriesFriendsQL = r'''
query getUserFriendsStoriesFriends($currentUserEmail: String!, $limit: String!, $cursor: String!) {
userFriendsStoriesFriends(
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
getUserByName(name: $name, currentUserEmail: $currentUserEmail)''' +
    _user_ +
    '''
}
''';

const String getUserFriendQL = r'''
query getUserFriend($email: String!, $otherEmail: String!) {
userFriend(email: $email, otherEmail: $otherEmail) {
    id
    email
    name
    home
    created {
      formatted
    }
    image
    isFriend
  }
}
''';

const String addUserBannedQL = r'''
mutation addUserBanned($from: _UserInput!, $to: _UserInput!, $data: _BannedInput!) {
AddUserBanned(
  from: $from, 
  to: $to,
  data: $data
  ) {
    from {
      email
      name
    }
    to {
      email
      id
      name
    }
    id
    created {
      formatted
    }
  }
}
''';

const String removeUserBannedQL = r'''
mutation removeUserBanned($from: _UserInput!, $to: _UserInput!) {
RemoveUserBanned(
  from: $from, 
  to: $to
  ) {
    from {
      email
      name
    }
    to {
      email
      id
      name
    }
  }
}
''';

const String deleteBannedQL = r'''
mutation deleteBanned($email: String!) {
deleteBanned(
  email: $email
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
