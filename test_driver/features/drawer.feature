Feature: Drawer

    @first
    Scenario: create book and story and assign story to book
        Given I open the drawer
        And I fill the "emailTextField" field with "testname@myfamilyvoice.com"
        And I tap the "submitButton" button
        And I close the drawer
        #Now on Profile page
        Then I expect the "emailFormField" to be "testname@myfamilyvoice.com"
        Given I tap the "storyPageGalleryButton" button
        And I fill the "nameFormField" field with "Test Name"
        And I fill the "homeFormField" field with "Home City, State"
        And I pause for 1 seconds
        And I tap the "profilePageUploadButton" button
        Then I expect the text "Save successful" to be present within the "toastContainer"
        #Create a Book
        Given I tap the "mainFloatingActionButton" widget
        Given I tap the "bookFloatingActionButton" widget
        Given I tap the "storyPageGalleryButton" button
        And I fill the "nameFormField" field with "Book Name"
        And I fill the "homeFormField" field with "Book Home City, State"
        And I pause for 1 seconds
        And I tap the "profilePageUploadButton" button
        Then I expect the text "Save successful" to be present within the "toastContainer"
        Then I tap the back button
        #Create a Story
        Given I tap the "mainFloatingActionButton" widget
        And I tap the "storyFloatingActionButton" widget
        And I tap the "storyPageGalleryButton" button
        And I tap the "recorderWidgetRecordButton" button
        And I pause for 3 seconds
        And I tap the "recorderWidgetStopButton" button
        Then I expect the text "Save successful" to be present within the "toastContainer"
        Then I expect the widget "deleteStoryButton" to be present within 3 seconds
        # On Story add attention to Book which should send a "attention" notification to the Book
        And I tap the "storyPlayAttentionButton" button
        And I fill the "tagFriendsPageSearch" field with "Book"
        And I tap the "tagFriendsPage-Book Name" widget
        And I pause for 1 seconds
        And I tap the "tagFreindsPageSave" button
        And I swipe up by 500 pixels on the "storyPlayScrollView"
        Then I expect the "userName-Test Name" to be "Test Name"
        And I expect the "userHome-Test Name" to be "Home City, State"
        # Assign the story to a Book
        Given I tap the "storyPlayBookButton" button
        And I fill the "tagFriendsPageSearch" field with "Book"
        And I tap the "tagFriendsPage-Book Name" widget
        And I pause for 1 seconds
        And I tap the "tagFreindsPageSave" button
        And I swipe up by 500 pixels on the "storyPlayScrollView"
        Then I expect the "userName-Book Name" to be "Book Name"
        And I expect the "userHome-Book Name" to be "Book Home City, State"
        And I tap the "backButton" button
        #Expect testname@myfamilyvoice.com to have a notification
        And I tap the text that contains the text "Notices"
        Then I expect the "message-title" to be "Attention"
        And I expect the "userName-Test Name" to be "Test Name"
        And I expect the "userHome-Test Name" to be "Home City, State"
        #Clear the messages and validate there are no others
        Given I tap the button that contains the text "Clear"
        Then I expect the "noMessages" to be "No results"
        #Log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds

    @second
    Scenario: login as Barton and make FriendRequest to Book
        #Log in as user
        Given I open the drawer
        Given I fill the "emailTextField" field with "bartonhammond@gmail.com"
        Given I tap the "submitButton" button
        And I close the drawer
        Then I expect the widget "Stories" to be present within 10 seconds
        #Make friendRequest to Book
        And I tap the text that contains the text "Users"
        And I fill the "searchField" field with "Book"
        And I pause for 1 seconds
        Then I tap the button that contains the text "Friend?"
        Given I tap the "alertDefault" button
        And I pause for 1 seconds
        Then I expect the text "Pending" to be present
        #Log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds
        #Log in as the person who had created the book
        Given I open the drawer
        And I fill the "emailTextField" field with "testname@myfamilyvoice.com"
        Given I tap the "submitButton" button
        And I close the drawer
        Then I expect the widget "Stories" to be present within 10 seconds
        #Check notices
        And I tap the text that contains the text "Notices"
        Then I expect the "message-title" to be "Friend Request"
        And I expect the "userName-Book Name" to be "Book Name"
        And I expect the "userHome-Book Name" to be "Book Home City, State"
        And I expect the "userName-Barton Hammond" to be "Barton Hammond"
        And I expect the "userHome-Barton Hammond" to be "Fond du Lac, WI"
        #Clear the messages and validate there are no others
        Given I tap the button that contains the text "Approve"
        And I tap the "alertDefault" button
        Then I expect the "noMessages" to be "No results"
        #Clear the existing notificiation
        And I tap the text that contains the text "Notices"
        Then I expect the "noMessages" to be "No results"
        #Log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds

    @third
    Scenario: login as Barton, verify attention and add comment
        #Log in as Barton
        Given I open the drawer
        Given I fill the "emailTextField" field with "bartonhammond@gmail.com"
        Given I tap the "submitButton" button
        And I close the drawer
        Then I expect the widget "Stories" to be present within 10 seconds
        Then I expect the "userName-Book Name" to be "Book Name"
        And I expect the "userHome-Book Name" to be "Book Home City, State"
        #Scroll so that the FriendWidget isn't visible
        #so that the "Book Name" is found with the Attention button
        And I swipe down by 250 pixels on the "storiesPageExpanded"
        Given I tap the "attentionButton-Book Name" button
        Then I expect the "itemText-Book Name" to be "Book Name"
        Given I tap the "attentionButton-Book Name" button
        And I wait until the widget of type "Tags" is absent
        #make comment
        Given I tap the "commentButton-0" text
        And I tap the "recorderWidgetRecordButton" button
        And I pause for 3 seconds
        And I tap the "recorderWidgetStopButton" button
        And I pause for 3 seconds
        Then I expect the text "Record" to be absent
        #Log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds

    @fourth
    Scenario: Login as test user and confirm the comment message
        Given I open the drawer
        And I fill the "emailTextField" field with "testname@myfamilyvoice.com"
        Given I tap the "submitButton" button
        And I close the drawer
        Then I expect the widget "Stories" to be present within 10 seconds
        #Verify the Comment
        Given I tap the text that contains the text "Notices"
        Then I expect the "message-title" to be "Comment"
        And I tap the "viewCommentButton-0" widget
        #Verify we went to the Story
        Then I expect the "userName-Book Name" to be "Book Name"
        And I expect the "userHome-Book Name" to be "Book Home City, State"
        #go back
        And I tap the "backButton" button
        Then I expect the "noMessages" to be "No results"
        #Log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds

    @fifth
    Scenario: login as Barton and ban Test Name and then unban him
        #Log in as Barton
        Given I open the drawer
        Given I fill the "emailTextField" field with "bartonhammond@gmail.com"
        Given I tap the "submitButton" button
        And I close the drawer
        Then I expect the widget "Stories" to be present within 10 seconds
        Then I expect the "userName-Book Name" to be "Book Name"
        And I expect the "userHome-Book Name" to be "Book Home City, State"
        #Scroll so that the FriendWidget isn't visible
        And I swipe down by 225 pixels on the "storiesPageExpanded"
        Then I expect the "originalUser-Test Name" to be "Test Name"
        And I tap the "originalUserBan-Test Name" widget
        Then I expect the widget "banConfirmation" to be present within 2 seconds
        Then I expect the text "Are you sure you want to ban?" to be present
        And I tap the "alertDefault" button
        And I pause for 2 seconds
        #Find the new banned book
        And I tap the text that contains the text "Users"
        And I fill the "searchField" field with "Book"
        Then I expect the "originalUser-Test Name" to be "Test Name"
        #Tap the "Ban" button and confirm that the dalog is to "Remove"
        Given I tap the "originalUserBan-Test Name" widget
        Then I expect the widget "banConfirmation" to be present within 2 seconds
        And I expect the text "Unban: 'Test Name'" to be present
        Then I tap the "alertDefault" button
        #Verify the story written by Test Name is now presented
        And I tap the text that contains the text "Stories"
        Then I expect the "userName-Book Name" to be "Book Name"
        And I expect the "userHome-Book Name" to be "Book Home City, State"
        #Log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds

    @sixth
    Scenario: test family.
        #create a user "familystoryProvider" that makes one story for family
        Given I open the drawer
        And I fill the "emailTextField" field with "familystoryprovider@myfamilyvoice.com"
        And I tap the "submitButton" button
        And I close the drawer
        #Now on Profile page
        Then I expect the "emailFormField" to be "familystoryprovider@myfamilyvoice.com"
        Given I tap the "storyPageGalleryButton" button
        And I fill the "nameFormField" field with "Family Story Provider"
        And I fill the "homeFormField" field with "Home City, State"
        And I pause for 1 seconds
        And I tap the "profilePageUploadButton" button
        Then I expect the text "Save successful" to be present within the "toastContainer"
        #Create a Story which is Family
        Given I tap the "mainFloatingActionButton" widget
        And I tap the "storyFloatingActionButton" widget
        And I tap the "storyPageGalleryButton" button
        And I tap the "recorderWidgetRecordButton" button
        And I pause for 3 seconds
        And I tap the "recorderWidgetStopButton" button
        Then I expect the text "Save successful" to be present within the "toastContainer"
        Then I expect the widget "deleteStoryButton" to be present within 3 seconds
        Then I tap the "radioGroupFamily" widget
        And I pause for 1 seconds
        Then I expect the text "Save successful" to be present within the "toastContainer"
        And I tap the "backButton" button
        #Log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds
        #create a new user "familystoryFriend" that request friend to "familystoryprovider"
        Given I open the drawer
        And I fill the "emailTextField" field with "familystoryfriend@myfamilyvoice.com"
        And I tap the "submitButton" button
        And I close the drawer
        #Now on Profile page
        Then I expect the "emailFormField" to be "familystoryfriend@myfamilyvoice.com"
        Given I tap the "storyPageGalleryButton" button
        And I fill the "nameFormField" field with "Family Story Friend"
        And I fill the "homeFormField" field with "Home City, State"
        And I pause for 1 seconds
        And I tap the "profilePageUploadButton" button
        Then I expect the text "Save successful" to be present within the "toastContainer"
        #Find the Family Story Provider
        And I tap the text that contains the text "Users"
        And I fill the "searchField" field with "Provider"
        And I tap the "newFriendsButton-familystoryprovider@myfamilyvoice.com" button
        And I pause for 1 seconds
        Given I tap the "alertDefault" button
        And I pause for 1 seconds
        Then I expect the text "Pending" to be present
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds
        #log in as familystoryprovider and approve friend request
        Given I open the drawer
        And I fill the "emailTextField" field with "familystoryprovider@myfamilyvoice.com"
        And I tap the "submitButton" button
        And I close the drawer
        Given I tap the text that contains the text "Notices"
        Then I expect the "message-title" to be "Friend Request"
        And I tap the "friend-request-approve-familystoryfriend@myfamilyvoice.com" widget
        Then I expect the widget "approveFriendRequest" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the "noMessages" to be "No results"
        #log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds
        #log back in as "familystoryFriend" and confirm Stories is "No Results"
        Given I open the drawer
        And I fill the "emailTextField" field with "familystoryfriend@myfamilyvoice.com"
        And I tap the "submitButton" button
        And I close the drawer
        Then I expect the widget "Stories" to be present within 10 seconds
        Then I expect the "noMessages" to be "No results"
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds
        #log back in as "familystoryProvider" and change "familystoryFriend" to be family
        And I open the drawer
        And I fill the "emailTextField" field with "familystoryprovider@myfamilyvoice.com"
        And I tap the "submitButton" button
        And I close the drawer
        And I tap the text that contains the text "Users"
        And I fill the "searchField" field with "Friend"
        And I tap the "familyCheckbox-familystoryfriend@myfamilyvoice.com" widget
        #log back in as "familyStoryFriend" and confirm Stories now sees one Story which is "Family"
        Given I open the drawer
        And I fill the "emailTextField" field with "familystoryfriend@myfamilyvoice.com"
        And I tap the "submitButton" button
        And I close the drawer
        And I tap the text that contains the text "Stories"
        Then I expect the "userName-Family Story Provider" to be "Family Story Provider"
        And I expect the "userHome-Family Story Provider" to be "Home City, State"
        And I expect the "storyPlayAudience" to be "FAMILY"
        #logout
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds


    @seventh
    Scenario: Login as Test User and exercise all the dropdown menu options
        # Exercise the Stories dropdowns
        Given I open the drawer
        And I fill the "emailTextField" field with "testname@myfamilyvoice.com"
        Given I tap the "submitButton" button
        And I close the drawer
        Then I expect the widget "Stories" to be present within 10 seconds
        Then I expect the "userName-Book Name" to be "Book Name"
        And I expect the "userHome-Book Name" to be "Book Home City, State"
        Given I tap the widget that contains the text "All"
        Then I expect the text "Family" to be present
        Given I tap the "storiesPageFamily" text without scrolling it into view
        Then I expect the "noMessages" to be "No results"
        Given I tap the "storiesPageFamily" text
        Given I tap the "storiesPageFriends" text without scrolling it into view
        Then I expect the "userName-Book Name" to be "Book Name"
        And I expect the "userHome-Book Name" to be "Book Home City, State"
        Given I tap the "storiesPageFriends" text
        And I tap the "storiesPageMe" text without scrolling it into view
        Then I expect the "noMessages" to be "No results"
        #logout
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds
        #Do same tests except w/ user that is a Family
        Given I open the drawer
        And I fill the "emailTextField" field with "familystoryfriend@myfamilyvoice.com"
        And I tap the "submitButton" button
        And I close the drawer
        And I tap the text that contains the text "Stories"
        Then I expect the "userName-Family Story Provider" to be "Family Story Provider"
        And I expect the "userHome-Family Story Provider" to be "Home City, State"
        Given I tap the widget that contains the text "All"
        Then I expect the text "Family" to be present
        Given I tap the "storiesPageFamily" text without scrolling it into view
        Then I expect the "userName-Family Story Provider" to be "Family Story Provider"
        And I expect the "userHome-Family Story Provider" to be "Home City, State"
        Given I tap the "storiesPageFamily" text
        Given I tap the "storiesPageFriends" text without scrolling it into view
        Then I expect the "noMessages" to be "No results"
        Given I tap the "storiesPageFriends" text
        And I tap the "storiesPageMe" text without scrolling it into view
        Then I expect the "noMessages" to be "No results"
        #logout
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds
        #Exercise the Users dropdowns
        Given I open the drawer
        And I fill the "emailTextField" field with "testname@myfamilyvoice.com"
        Given I tap the "submitButton" button
        And I close the drawer
        Given I tap the text that contains the text "Users"
        Then I expect the "userName-Admin MyFamilyVoice" to be "Admin MyFamilyVoice"
        Given I tap the widget that contains the text "All"
        Then I expect the text "Family" to be present
        Given I tap the "usersPageFamily" text without scrolling it into view
        Then I expect the "noMessages" to be "No results"
        Given I tap the "usersPageFamily" text
        Given I tap the "usersPageFriends" text without scrolling it into view
        Then I expect the "userName-Book Name" to be "Book Name"
        And I expect the "userHome-Book Name" to be "Book Home City, State"
        Given I tap the "usersPageFriends" text
        Given I tap the "usersPageBooks" text without scrolling it into view
        Then I expect the "userName-Book Name" to be "Book Name"
        And I expect the "userHome-Book Name" to be "Book Home City, State"
        Given I tap the "usersPageBooks" text
        Given I tap the "usersPageUsers" text without scrolling it into view
        Then I expect the "userName-Admin MyFamilyVoice" to be "Admin MyFamilyVoice"
        Given I tap the "usersPageUsers" text
        Given I tap the "usersPageMe" text without scrolling it into view
        Then I expect the "userName-Test Name" to be "Test Name"
        #Exercise the Notices dropdowns
        Given I tap the text that contains the text "Notices"
        Then I expect the "noMessages" to be "No results"
        Given I tap the widget that contains the text "All"
        Given I tap the "messagesPageAttention" text without scrolling it into view
        Then I expect the "noMessages" to be "No results"
        Given I tap the "messagesPageAttention" text
        Given I tap the "messagesPageMessage" text without scrolling it into view
        Then I expect the "noMessages" to be "No results"
        Given I tap the "messagesPageMessage" text
        Given I tap the "messagesPageComment" text without scrolling it into view
        Then I expect the "noMessages" to be "No results"
        Given I tap the "messagesPageComment" text
        Given I tap the "messagesPageFriendRequest" text without scrolling it into view
        Then I expect the "noMessages" to be "No results"
        #logout
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds
        #login as provider and verify users.family shows familystoryfriend
        And I open the drawer
        And I fill the "emailTextField" field with "familystoryprovider@myfamilyvoice.com"
        And I tap the "submitButton" button
        And I close the drawer
        Given I tap the text that contains the text "Users"
        Given I tap the widget that contains the text "All"
        Then I expect the text "Family" to be present
        Given I tap the "usersPageFamily" text without scrolling it into view
        Then I expect the "userName-Family Story Friend" to be "Family Story Friend"
        And I expect the "userHome-Family Story Friend" to be "Home City, State"
        #Log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds

    @eighth
    Scenario: Validate the Reactions table
        #Login as bartonhammond
        Given I open the drawer
        Given I fill the "emailTextField" field with "bartonhammond@gmail.com"
        Given I tap the "submitButton" button
        And I close the drawer
        Then I expect the widget "Stories" to be present within 10 seconds
        Then I expect the "userName-Book Name" to be "Book Name"
        And I expect the "userHome-Book Name" to be "Book Home City, State"
        #Scroll down to see the Like button and click the "like"
        Then I swipe down by 150 pixels on the "storiesPageColumn"
        And I long press the 'reaction-0' widget
        And I pause for 1 seconds
        And I tap the first 'ReactionsBoxItem' of parent type 'ReactionsBox'
        #Log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds
        #Log in as testname and verify the reactions
        Given I open the drawer
        Given I fill the "emailTextField" field with "testname@myfamilyvoice.com"
        Given I tap the "submitButton" button
        And I close the drawer
        Then I expect the widget "Stories" to be present within 10 seconds
        Then I expect the "userName-Book Name" to be "Book Name"
        And I expect the "userHome-Book Name" to be "Book Home City, State"
        #Scroll down to see the reaction totals
        Then I swipe down by 150 pixels on the "storiesPageColumn"
        And I tap the "reactionTotals-0" widget
        Then I swipe down by 200 pixels on the "storiesPageColumn"
        And I expect the text "Friend?" to be present
        #make a friend request
        Then I tap the widget that contains the text "Friend?"
        Then I expect the widget "reactionTableFriendRequest" to be present within 2 seconds
        Given I tap the "alertDefault" button
        And I expect the text "Pending" to be present
        #log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        #Log in as bartonhammond@gmail and approve the friend request
        Given I open the drawer
        Given I fill the "emailTextField" field with "bartonhammond@gmail.com"
        Given I tap the "submitButton" button
        And I close the drawer
        Then I expect the widget "Stories" to be present within 10 seconds
        #Check notices for friend request
        And I tap the text that contains the text "Notices"
        Then I expect the "message-title" to be "Friend Request"
        And I expect the "userName-Test Name" to be "Test Name"
        And I expect the "userHome-Test Name" to be "Home City, State"
        #approve friend request
        Given I tap the button that contains the text "Approve"
        And I tap the "alertDefault" button
        Then I expect the "noMessages" to be "No results"
        #log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        #Log in as testname and verify the reactions shows Message for bartonhammond
        Given I open the drawer
        Given I fill the "emailTextField" field with "testname@myfamilyvoice.com"
        Given I tap the "submitButton" button
        And I close the drawer
        Then I expect the widget "Stories" to be present within 10 seconds
        #Scroll down to see the reaction totals
        Then I swipe down by 150 pixels on the "storiesPageColumn"
        And I tap the "reactionTotals-0" widget
        Then I swipe down by 200 pixels on the "storiesPageColumn"
        And I expect the text "Message?" to be present
        #Click the Message button and verify barton hammond is displayed
        Then I tap the widget that contains the text "Message?"
        Then I expect the "userName-Barton Hammond" to be "Barton Hammond"
        And I expect the "userHome-Barton Hammond" to be "Fond du Lac, WI"
        And I tap the 'message-display' widget
        #Record a message
        And I expect the text "Record Message" to be present
        And I tap the "recorderWidgetRecordButton" button
        And I pause for 3 seconds
        And I tap the "recorderWidgetStopButton" button
        And I expect the text "Record Message" to be absent
        Then I tap the back button
        #log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        #Log in as testname and verify the reactions shows Message for bartonhammond
        Given I open the drawer
        Given I fill the "emailTextField" field with "bartonhammond@gmail.com"
        Given I tap the "submitButton" button
        And I close the drawer
        Then I expect the widget "Stories" to be present within 10 seconds
        #Check notices for friend request
        And I tap the text that contains the text "Notices"
        Then I expect the "message-title" to be "Message"
        And I expect the "userName-Test Name" to be "Test Name"
        And I expect the "userHome-Test Name" to be "Home City, State"
        Given I tap the text that contains the text "Delete Message"
        Then I expect the "noMessages" to be "No results"



