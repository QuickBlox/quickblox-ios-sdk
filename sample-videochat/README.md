<h2> QuickBlox Sample VideoChat iOS</h2>
This is a code sample for [QuickBlox](http://quickblox.com/) platform. It is a great way for developers using QuickBlox platform to learn how to integrate 1 on 1 video conference into your application.

Original sample description & setup guide - [http://quickblox.com/developers/SimpleSample-videochat-ios](http://quickblox.com/developers/SimpleSample-videochat-ios)

![VideoChat sample Home screen](http://files.quickblox.com/iOS-QB_VideoChat_sample2.png) &nbsp;&nbsp;&nbsp;&nbsp; ![Video conference](http://files.quickblox.com/iOS-QB_VideoChat_sample1.png)

<h3>Important - how to build your own VideoChat app</h3>

If you want to build your own iOS VideoChat app, please do the following:<br />
1) download the project from here (GIT)<br />
2) register a QuickBlox account (if you don't have one yet): http://admin.quickblox.com/register<br />
3) log in to QuickBlox admin panel http://admin.quickblox.com/signin<br />
4) create a new app and create two users in that app - IMPORTANT: make the username and the password for each user the same.  For example: if you make the first username johntest1 it needs to have the password also as johntest1 <br />
5) click on the app title in the list to reveal app details:<br />

![App credentials](http://files.quickblox.com/QuickBlox_application_credentials.png)

6) copy credentials (App ID, Authorization key, Authorization secret) into your VideoChat project code along with the two users you created. Since the username and the password are the same, you do not need to put separately the username and password in the code but only the name (for example johntest1) along with the ID of the user in the file /VideoChat-sample-ios/AppDelegate.m<br />
7) Enjoy!
