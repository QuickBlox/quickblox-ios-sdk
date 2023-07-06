<div align="center">

<p>
		<a href="https://discord.gg/c6bxq9BC"><img src="https://img.shields.io/discord/1042743094833065985?color=5865F2&logo=discord&logoColor=white&label=QuickBlox%20Discord%20server&style=for-the-badge" alt="Discord server" /></a>
</p>

</div>


# Overview

QuickBlox iOS Sample UIKit (Swift)

This is a code sample for [QuickBlox](https://quickblox.com) platform. It is a great way for developers using QuickBlox platform to learn how to integrate private and group chat, add text and image attachments sending into your application.

# Get Application Credentials

QuickBlox application includes everything that brings messaging right into your application - chat, video calling, users, push notifications, etc. To create a QuickBlox application, follow the steps below:

1. Register a new account following this [link](https://admin.quickblox.com/signup). Type in your email and password to sign in. You can also sign in with your Google or Github accounts.
2. Create the app clicking **New app** button.
3. Configure the app. Type in the information about your organization into corresponding fields and click **Add** button.
4. Go to **Dashboard => *YOUR_APP* => Overview** section and copy your **Application ID**,  **Authorization Key**,  **Authorization Secret**,  and **Account Key** .

# UIKit Sample

This Sample demonstrates how to work with [UIKit](https://docs.quickblox.com/docs/ios-uikit) QuickBlox module. 

# Features

It allows to:

1. Login/logout with Quickblox Chat and REST.
2. List of dialogs
3. Create dialog(Private or Group)
4. Dialog screen
5. Send text, image, video, audio, file messages
6. Dialog info screen
7. List, invite, remove members

# Run UIKit Sample

To run a code sample, follow the steps below:

1. [Get application credentials](#get-application-credentials).
2. Put the received credentials in ```Connect``` file located in the root directory of your project.

```json
Quickblox.initWithApplicationId(92,
                                authKey: "wJHdOcQSxXQGWx5",
                                authSecret: "BTFsj7Rtt27DAmT",
                                accountKey: "7yvNe17TnjNUqDoPwfqp")
```
3. Run the code sample.
