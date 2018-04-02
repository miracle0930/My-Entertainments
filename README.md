# My-Entertainments
Build your movie database and meet more friends.

## Animations
### Search Movie
<p align="center"><img src="https://github.com/miracle0930/My-Entertainments/blob/master/Screenshots/movieSearchDemo.gif" /></p>
### Movie Detail
<p align="center"><img src="https://github.com/miracle0930/My-Entertainments/blob/master/Screenshots/movieDetailDemo.gif" /></p>
### Chatting
<p align="center"><img src="https://github.com/miracle0930/My-Entertainments/blob/master/Screenshots/chattingDemo.gif" /></p>

## Features
- Search movies according movies title, buntches of movies will show up.
- Favorite list, for users to build their personal movie databases.
- Friends, add more friends and share your favorite movies with them.
- Chatting with your friend.
- Used GCD (Grand Central Dispatch) and NSCache to optimize the performance when user scroll the tableview.
- Settled listeners on Firebase real-time database to observe new incomming event (message, friend request).
- Used NSNotificationCenter to reload data when there the structure of the real-time database changed.

## Direcroty
Directory name | Introduction
---|---
Models | Contained all realm database supported classes which were used in application. `UserAccount.swift` worked as the root class and all other classes works as features of this class.
View | Contained tableview cell and collection view cell.
Controllers | Contained five main viewcontrollers for this application, all functions will be loaded when the `SearchViewController.swift` was loaded.
Delegate | Protocols to call sidemenu, receive new message etc.

