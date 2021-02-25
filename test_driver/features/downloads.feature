Feature: downloads
    @downloads
    Scenario: Confirm downloads are working
        Given I open the drawer
        And I fill the "emailTextField" field with "downloads@myfamilyvoice.com"
        And I tap the "submitButton" button
        And I close the drawer
        #Now on Profile page
        Then I expect the "emailFormField" to be "downloads@myfamilyvoice.com"
        Given I tap the "storyPageGalleryButton" button
        And I fill the "nameFormField" field with "Downloads"
        And I fill the "homeFormField" field with "Downloads, State"
        And I pause for 1 seconds
        And I tap the "profilePageUploadButton" button
        Then I expect the text "Save successful" to be present within the "toastContainer"
        # Make sure that Profile doesn't show the button to download if there are no Stories
        Given I tap the text that contains the text "Stories"
        And I pause for 1 seconds
        Then I expect the "noMessages" to be "No results"
        Given I tap the text that contains the text "Profile"
        And I expect the text "Download" to be absent
        #Create a Story
        Given I tap the "mainFloatingActionButton" widget
        And I tap the "storyFloatingActionButton" widget
        And I tap the "storyPageGalleryButton" button
        And I tap the "recorderWidgetRecordButton" button
        And I pause for 3 seconds
        And I tap the "recorderWidgetStopButton" button
        And I pause for 3 seconds
        Then I expect the text "Save successful" to be present within the "toastContainer"
        Then I expect the widget "deleteStoryButton" to be present within 5 seconds
        And I tap the "backButton" button
        Given I tap the text that contains the text "Stories"
        And I pause for 1 seconds
        Given I tap the text that contains the text "Profile"
        And I pause for 1 seconds
        And I expect the text "Download" to be present
        And I tap the "profilePageDownloadButton" button
        And I expect the text "Save" to be present
        And I expect the text "Number of stories: 1" to be present
        And I tap the "downloadPageDownload" button
        And I pause for 3 seconds
        And I expect the text "View Summary?" to be present
        Then I tap the back button
        #Log out
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 5 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 5 seconds