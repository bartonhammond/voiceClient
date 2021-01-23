Feature: Drawer

    @first
    Scenario: login as new user
        Given I open the drawer
        And I fill the "emailTextField" field with "testname@myfamilyvoice.com"
        And I tap the "submitButton" button
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
        #Find the new Book User
        And I tap the text that contains the text "Users"
        And I fill the "searchField" field with "Book"
        #Become the Book
        And I tap the "manageButton-Book Name" button
        And I tap the text that contains the text "Profile"
        Then I expect the "nameFormField" "TextFormField" to be "Book Name"
        And I expect the "homeFormField" "TextFormField" to be "Book Home City, State"
        #Quit Manage the Book
        Then I tap the "proxyButton" button
        And I tap the "alertDefault" button
        And I pause for 1 seconds
        Then I expect the "nameFormField" "TextFormField" to be "Test Name"
        And I expect the "homeFormField" "TextFormField" to be "Home City, State"
        #Create a Story
        Given I tap the "mainFloatingActionButton" widget
        And I tap the "storyFloatingActionButton" widget
        And I tap the "storyPageGalleryButton" button
        And I tap the "recorderWidgetRecordButton" button
        And I pause for 3 seconds
        And I tap the "recorderWidgetStopButton" button
        Then I expect the text "Save successful" to be present within the "toastContainer"
        Then I expect the widget "deleteStoryButton" to be present within 3 seconds
        # On Story add attention to Book which should send a "attention" notification to the Book and a manage to the bookAuthor
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
        #Expect testname@myfamilyvoice.com to have a "Manage" notification
        And I tap the text that contains the text "Notices"
        Then I expect the "message-title" to be "Manage"
        #Manage the Book
        And I tap the "manageButton-Book Name" button
        # Now, as the Manager of Book, Verify a message was sent from the Attention
        And I tap the text that contains the text "Notices"
        Then I expect the "message-title" to be "Attention"
        And I expect the "userName-Test Name" to be "Test Name"
        And I expect the "userHome-Test Name" to be "Home City, State"
        #Clear the messages and validate there are no others
        Given I tap the button that contains the text "Clear"
        Then I expect the "noMessages" to be "No results"
        #Quit proxy while still  on Notices
        Then I tap the "proxyButton" button
        And I tap the "alertDefault" button
        Then I expect the "message-title" to be "Manage"
        Then I expect the "userName-Book Name" to be "Book Name"
        And I expect the "userHome-Book Name" to be "Book Home City, State"
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
        Then I expect the widget "Stories" to be present within 10 seconds
        #Check notices
        And I tap the text that contains the text "Notices"
        Then I expect the "userName-Book Name" to be "Book Name"
        And I expect the "userHome-Book Name" to be "Book Home City, State"
        And I tap the "manageButton-Book Name" button
        And I tap the text that contains the text "Profile"
        Then I expect the "nameFormField" "TextFormField" to be "Book Name"
        And I expect the "homeFormField" "TextFormField" to be "Book Home City, State"
        #Accept the Friend Request
        Given I tap the text that contains the text "Notices"
        Then I expect the "message-title" to be "Friend Request"
        And I expect the "userName-Barton Hammond" to be "Barton Hammond"
        And I expect the "userHome-Barton Hammond" to be "Fond du Lac, WI"
        #Clear the messages and validate there are no others
        Given I tap the button that contains the text "Approve"
        And I tap the "alertDefault" button
        Then I expect the "noMessages" to be "No results"
        #Quit Manage the Book
        Then I tap the "proxyButton" button
        And I tap the "alertDefault" button
        And I tap the text that contains the text "Profile"
        Then I expect the "nameFormField" "TextFormField" to be "Test Name"
        And I expect the "homeFormField" "TextFormField" to be "Home City, State"
        #Clear the existing Manage notificiation
        And I tap the text that contains the text "Notices"
        Then I expect the "message-title" to be "Manage"
        Then I expect the "userName-Book Name" to be "Book Name"
        And I expect the "userHome-Book Name" to be "Book Home City, State"
        Given I tap the button that contains the text "Clear"
        Then I expect the "noMessages" to be "No results"
        #Log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds

    @third
    Scenario: login as Barton
        #Log in as Barton
        Given I open the drawer
        Given I fill the "emailTextField" field with "bartonhammond@gmail.com"
        Given I tap the "submitButton" button
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
    Scenario: Login as test user, manage the book and confirm the comment message
        Given I open the drawer
        And I fill the "emailTextField" field with "testname@myfamilyvoice.com"
        Given I tap the "submitButton" button
        Then I expect the widget "Stories" to be present within 10 seconds
        #Find the new Book User
        And I tap the text that contains the text "Users"
        And I fill the "searchField" field with "Book"
        And I tap the "manageButton-Book Name" button
        And I tap the text that contains the text "Profile"
        Then I expect the "nameFormField" "TextFormField" to be "Book Name"
        And I expect the "homeFormField" "TextFormField" to be "Book Home City, State"
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
        #Quit proxy while still  on Notices
        Then I tap the "proxyButton" button
        And I tap the "alertDefault" button
        Then I expect the "message-title" to be "Manage"
        Then I expect the "userName-Book Name" to be "Book Name"
        And I expect the "userHome-Book Name" to be "Book Home City, State"
        Given I tap the button that contains the text "Clear"
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

    @sixth
    Scenario: Login as Test User and exercise all the dropdown menu options
        Given I open the drawer
        And I fill the "emailTextField" field with "testname@myfamilyvoice.com"
        Given I tap the "submitButton" button
        And I close the drawer
        # Exercise the Stories dropdowns
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
        #Exercise the Users dropdowns
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
        Given I tap the "messagesPageFriendRequest" text
        Given I tap the "messagesPageManage" text without scrolling it into view
        Then I expect the "noMessages" to be "No results"






