Feature: Book

    @tenth
    Scenario: One book, two contributors (one is family) verify stories shown on Users page
        Given I open the drawer
        And I fill the "emailTextField" field with "album_maker@mfv.com"
        And I tap the "submitButton" button
        And I close the drawer
        #Now on Profile page
        Then I expect the "emailFormField" to be "album_maker@mfv.com"
        Given I tap the "storyPageGalleryButton" button
        And I fill the "nameFormField" field with "Album Maker"
        And I fill the "homeFormField" field with "Album Maker Home City, State"
        And I pause for 1 seconds
        And I tap the "profilePageUploadButton" button
        Then I expect the text "Save successful" to be present within the "toastContainer"
        #Create a Book
        Given I tap the "mainFloatingActionButton" widget
        Given I tap the "bookFloatingActionButton" widget
        Given I tap the "storyPageGalleryButton" button
        And I fill the "nameFormField" field with "Album Name"
        And I fill the "homeFormField" field with "Album Name Home City, State"
        And I pause for 1 seconds
        And I tap the "profilePageUploadButton" button
        Then I expect the text "Save successful" to be present within the "toastContainer"
        Then I tap the back button
        #Log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds
        #Log in and make friend request to Album
        Given I open the drawer
        Given I fill the "emailTextField" field with "friendToAlbum@mfv.com"
        Given I tap the "submitButton" button
        And I close the drawer
        Then I expect the widget "Stories" to be present within 10 seconds
        #Now on Profile page
        Then I expect the "emailFormField" to be "friendToAlbum@mfv.com"
        Given I tap the "storyPageGalleryButton" button
        And I fill the "nameFormField" field with "Friend To Album"
        And I fill the "homeFormField" field with "Friend to Album Home City, State"
        And I pause for 1 seconds
        And I tap the "profilePageUploadButton" button
        Then I expect the text "Save successful" to be present within the "toastContainer"
        #Make friendRequest to Book
        And I tap the text that contains the text "Users"
        Given I tap the widget that contains the text "All"
        Then I expect the text "Books" to be present
        Given I tap the "usersPageBooks" text without scrolling it into view
        And I fill the "searchField" field with "Album Name"
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
        #Log in as album maker and approve the request
        Given I open the drawer
        And I fill the "emailTextField" field with "album_maker@mfv.com"
        Given I tap the "submitButton" button
        And I close the drawer
        Then I expect the widget "Stories" to be present within 10 seconds
        #Check notices
        And I tap the text that contains the text "Notices"
        Then I expect the "message-title" to be "Friend Request"
        And I expect the "userName-Album Name" to be "Album Name"
        And I expect the "userHome-Album Name" to be "Album Name Home City, State"
        And I expect the "userName-Friend To Album" to be "Friend To Album"
        And I tap the "familyCheckbox-friendToAlbum@mfv.com" button
        And I tap the "friend-request-approve-friendToAlbum@mfv.com" widget
        Then I expect the widget "approveFriendRequest" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the "noMessages" to be "No results"
        #Log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds
        #Log in and confirm that friendToAlbum has no Stories
        Given I open the drawer
        Given I fill the "emailTextField" field with "friendToAlbum@mfv.com"
        Given I tap the "submitButton" button
        And I close the drawer
        Then I expect the widget "Stories" to be present within 10 seconds
        Then I expect the "noMessages" to be "No results"
        #Log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds
        #Log in as the book author album_maker and create a Story of type Friend
        Given I open the drawer
        And I fill the "emailTextField" field with "album_maker@mfv.com"
        And I tap the "submitButton" button
        And I close the drawer
        #Create a Story of type Friend
        Given I tap the "mainFloatingActionButton" widget
        And I tap the "storyFloatingActionButton" widget
        And I tap the "storyPageGalleryButton" button
        And I tap the "recorderWidgetRecordButton" button
        And I pause for 3 seconds
        And I tap the "recorderWidgetStopButton" button
        Then I expect the text "Save successful" to be present within the "toastContainer"
        Then I expect the widget "deleteStoryButton" to be present within 3 seconds
        # Assign the story to the Album Name Book
        Given I tap the "storyPlayBookButton" button
        And I fill the "tagFriendsPageSearch" field with "Album Name"
        And I tap the "tagFriendsPage-Album Name" widget
        And I pause for 1 seconds
        And I tap the "tagFreindsPageSave" button
        And I tap the "backButton" button
        #Log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds
        #Log in and confirm that friendToAlbum has no Stories
        Given I open the drawer
        Given I fill the "emailTextField" field with "friendToAlbum@mfv.com"
        Given I tap the "submitButton" button
        And I close the drawer
        Then I expect the widget "Stories" to be present within 10 seconds
        And I expect the "storyPlayAudience" to be "FRIENDS"
        Then I expect the "userName-Album Name" to be "Album Name"
        And I expect the "userHome-Album Name" to be "Album Name Home City, State"
        Given I tap the widget that contains the text "All"
        Then I expect the text "Family" to be present
        Given I tap the "storiesPageFamily" text without scrolling it into view
        Then I expect the "noMessages" to be "No results"
        #Log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds
        #Log in as the book author album_maker change Story to Family
        Given I open the drawer
        And I fill the "emailTextField" field with "album_maker@mfv.com"
        And I tap the "submitButton" button
        And I close the drawer
        And I tap the text that contains the text "Stories"
        And I tap the "friend_widget_clipRRect" widget
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
        #Log in and confirm that friendToAlbum has Stories Friend & Family
        Given I open the drawer
        Given I fill the "emailTextField" field with "friendToAlbum@mfv.com"
        Given I tap the "submitButton" button
        And I close the drawer
        Then I expect the widget "Stories" to be present within 10 seconds
        And I expect the "storyPlayAudience" to be "FAMILY"
        Then I expect the "userName-Album Name" to be "Album Name"
        And I expect the "userHome-Album Name" to be "Album Name Home City, State"
        Given I tap the widget that contains the text "All"
        Then I expect the text "Family" to be present
        Given I tap the "storiesPageFamily" text without scrolling it into view
        And I expect the "storyPlayAudience" to be "FAMILY"
        Then I expect the "userName-Album Name" to be "Album Name"
        And I expect the "userHome-Album Name" to be "Album Name Home City, State"
        Given I tap the "storiesPageFamily" text
        Given I tap the "storiesPageFriends" text without scrolling it into view
        Then I expect the "noMessages" to be "No results"
        #logout
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds
        #Log in as the book author album_maker
        #and confirm the story is still visible and says "FAMILY"
        Given I open the drawer
        And I fill the "emailTextField" field with "album_maker@mfv.com"
        And I tap the "submitButton" button
        And I close the drawer
        #Confirm the original author can still see the story he wrote
        #he should see the Family but not Friends drop down results
        And I tap the text that contains the text "Stories"
        Then I expect the widget "Stories" to be present within 10 seconds
        And I expect the "storyPlayAudience" to be "FAMILY"
        Then I expect the "userName-Album Name" to be "Album Name"
        And I expect the "userHome-Album Name" to be "Album Name Home City, State"
        Given I tap the widget that contains the text "All"
        Then I expect the text "Family" to be present
        Given I tap the "storiesPageFamily" text without scrolling it into view
        And I expect the "storyPlayAudience" to be "FAMILY"
        Then I expect the "userName-Album Name" to be "Album Name"
        And I expect the "userHome-Album Name" to be "Album Name Home City, State"
        Given I tap the widget that contains the text "Family"
        Given I tap the "storiesPageFriends" text without scrolling it into view
        Then I expect the "noMessages" to be "No results"
        Given I tap the widget that contains the text "Friends"
        Given I tap the "storiesPageFamily" text without scrolling it into view
        And I tap the "friend_widget_clipRRect" widget
        And I tap the widget that contains the text "Delete story?"
        Then I expect the widget "deleteStory" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the "noMessages" to be "No results"
        #logout
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds
















