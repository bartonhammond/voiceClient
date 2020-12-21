Feature: Drawer

    @newUser
    Scenario: login as new user
        Given I open the drawer
        And I fill the "emailTextField" field with "something@myfamilyvoice.com"
        And I tap the "submitButton" button
        #Now on Profile page
        Then I expect the "emailFormField" to be "something@myfamilyvoice.com"
        Given I tap the "storyPageGalleryButton" button
        And I fill the "nameFormField" field with "Test Name"
        And I fill the "homeFormField" field with "Home City, State"
        And I pause for 1 seconds
        And I tap the "profilePageUploadButton" button
        Then I expect the widget 'profileToast' to be present within 2 seconds
        #Create a Book
        Given I tap the "mainFloatingActionButton" widget
        Given I tap the "bookFloatingActionButton" widget
        Given I tap the "storyPageGalleryButton" button
        And I fill the "nameFormField" field with "Book Name"
        And I fill the "homeFormField" field with "Book Home City, State"
        And I pause for 1 seconds
        And I tap the "profilePageUploadButton" button
        Then I expect the widget 'profileToast' to be present within 2 seconds
        Then I tap the back button
        #Find the new Book User
        And I tap the text that contains the text "Users"
        And I fill the "searchField" field with "Book"
        #Become the Book
        And I tap the "messageButton-Book Name" button
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
        Then I expect the widget "profileToast" to be present within 2 seconds
        Then I expect the widget "deleteStoryButton" to be present within 2 seconds
        # Add attention to the Book
        And I tap the "storyPlayAttentionButton" button
        And I fill the "tagFriendsPageSearch" field with "Book"
        And I tap the "tagFriendsPage-Book Name" widget
        And I pause for 1 seconds
        And I tap the "tagFreindsPageSave" button
        And I swipe up by 500 pixels on the "storyPlayScrollView"
        Then I expect the "userName" to be "Test Name"
        And I expect the "userHome" to be "Home City, State"
        # Assign the story to a Book
        Given I tap the "storyPlayBookButton" button
        And I fill the "tagFriendsPageSearch" field with "Book"
        And I tap the "tagFriendsPage-Book Name" widget
        And I pause for 1 seconds
        And I tap the "tagFreindsPageSave" button
        And I swipe up by 500 pixels on the "storyPlayScrollView"
        Then I expect the "userName" to be "Book Name"
        And I expect the "userHome" to be "Book Home City, State"
        #Manage the Book
        And I tap the "messageButton-Book Name" button
        And I tap the "backButton" button
        # Now, as the Manager of Book, Verify a message was sent from the Attention
        And I tap the text that contains the text "Notices"
        Then I expect the "message-title" to be "Attention"
        And I expect the "userName" to be "Test Name"
        And I expect the "userHome" to be "Home City, State"
        #Clear the messages and validate there are no others
        Given I tap the button that contains the text "Clear"
        Then I expect the "noMessages" to be "No results"
        #Log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds

    @secondUser
    Scenario: login as Barton
        #Log in as user
        Given I open the drawer
        Given I fill the "emailTextField" field with "bartonhammond@gmail.com"
        Given I tap the "submitButton" button
        Then I expect the widget "Stories" to be present within 10 seconds
        #Make friendRequest to Book
        And I tap the text that contains the text "Users"
        And I fill the "searchField" field with "Book"
        Then I tap the button that contains the text "Friend?"
        Given I tap the "alertDefault" button
        Then I expect the text "Pending" to be present
        #Log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds
        #Log in as Book
        Given I open the drawer
        Given I fill the "emailTextField" field with "Book Name"
        Given I tap the "submitButton" button
        Then I expect the widget "Stories" to be present within 10 seconds
        #Accept the Friend Request
        Given I tap the text that contains the text "Notices"
        Then I expect the "message-title" to be "Friend Request"
        And I expect the "userName" to be "Barton Hammond"
        And I expect the "userHome" to be "Fond du Lac, WI"
        #Clear the messages and validate there are no others
        Given I tap the button that contains the text "Approve"
        And I tap the "alertDefault" button
        Then I expect the "noMessages" to be "No results"
        #Log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds
        #Log in as Barton
        Given I open the drawer
        Given I fill the "emailTextField" field with "bartonhammond@gmail.com"
        Given I tap the "submitButton" button
        Then I expect the widget "Stories" to be present within 10 seconds




