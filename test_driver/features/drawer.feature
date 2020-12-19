Feature: Drawer

    Scenario: login as existing user
        Given I open the drawer
        Given I fill the "emailTextField" field with "admin@myfamilyvoice.com"
        Given I tap the "submitButton" button
        Then I expect the widget "Stories" to be present within 10 seconds
        And I open the drawer
        And I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds

    @newuser
    Scenario: login as new user
        Given I open the drawer
        And I fill the "emailTextField" field with "something@myfamilyvoice.com"
        And I tap the "submitButton" button
        Then I expect the "emailFormField" to be "something@myfamilyvoice.com"
        Given I tap the "storyPageGalleryButton" button
        And I enter "Test Name" into the field with "Email" tooltip
        And I enter "Home City, State" into the field with "Home" tooltip
        And I pause for 1 seconds
        And I tap the "profilePageUploadButton" button
        Then I expect the widget 'profileToast' to be present within 2 seconds



