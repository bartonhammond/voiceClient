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
        And I fill the "nameFormField" field with "Test Name"
        And I fill the "homeFormField" field with "Home City, State"
        And I pause for 1 seconds
        And I tap the "profilePageUploadButton" button
        Then I expect the widget 'profileToast' to be present within 2 seconds
        Given I tap the "mainFloatingActionButton" widget
        Given I tap the "bookFloatingActionButton" widget
        Given I tap the "storyPageGalleryButton" button
        And I fill the "nameFormField" field with "Book Name"
        And I fill the "homeFormField" field with "Book Home City, State"
        And I pause for 1 seconds
        And I tap the "profilePageUploadButton" button
        Then I expect the widget 'profileToast' to be present within 2 seconds
        Then I tap the back button
        And I tap the text that contains the text "Users"
        And I fill the "searchField" field with "Book"
        And I tap the "messageButton-Book Name" button
        And I tap the text that contains the text "Profile"
        Then I expect the "nameFormField" textFormField to be "Book Name"
        And I expect the "homeFormField" textFormField to be "Book Home City, State"




