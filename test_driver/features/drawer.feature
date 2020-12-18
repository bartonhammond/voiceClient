Feature: Drawer

    Scenario: login as existing user
        Given I open the drawer
        Given I fill the "emailTextField" field with "admin@myfamilyvoice.com"
        Given I tap the "submitButton" button
        Then I expect the widget "Stories" to be present within 10 seconds
        And I open the drawer
        Then I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds


    Scenario: login as new user
        Given I open the drawer
        Given I fill the "emailTextField" field with "something@myfamilyvoice.com"
        Given I tap the "submitButton" button
        Then I expect the "emailFormField" to be "something@myfamilyvoice.com"
        And I open the drawer
        Then I tap the "signOutTile" widget
        Then I expect the widget "signOutConfirmation" to be present within 2 seconds
        Given I tap the "alertDefault" button
        Then I expect the widget "sendLinkButton" to be present within 2 seconds
