# Landmark

For Running the App You Need:

MacBook
 | Xcode Version 11.6 (Available from Mac AppStore)
 | iOS 13 Simulator (previous versions can be easily supported by minor modifications)

Pre-requisite:
User 4G or Unrestricted Internet

Cocoapods - https://guides.cocoapods.org/using/getting-started.html#getting-started

The app uses Firebase SDK ti support database and authentication operations

Once Cocapods is setup, open Terminal and navigate to you project folder. type "pod install" and enter and wait for the dependencies to download.

After the installation of the pods, open your .xcworkspace file to see the project in Xcode 11.6


The app has the following features:

Login as an existing user

Create a user

Stores the notes in a database

View a list of notes as a list view

Search for a note based on contained text or user-name

View the details of the notes - username, note text and the location

View the location of the notes on the map as annotatoins

Create a new note with location (or without)

As a user (of the application) you can see your current location on a map - Detail Page and MapView

The app misses the following features:

User logout

Password reset

Updating and Deleting notes


Code Standards:

The application need refactoring overall

Unit Tests are missing

Login Module follows the VIPER pattern

MapView uses a common LocationManager

CreateNote manages the location internally - this needs to be refactored to use the LocationManager (and VIPER of course)

The code refactoring hasn't been done in interest of time and progressing a sample (done is better than perfect) and parts of it intentionally to showcase the difference between coding standards.
