# Overview

QuickBlox iOS Sample Chat (Swift)

This is a code sample for [QuickBlox](https://quickblox.com) platform. It is a great way for developers using QuickBlox platform to learn how to integrate private and group chat, add text and image attachments sending into your application.

# Get Application Credentials

QuickBlox application includes everything that brings messaging right into your application - chat, video calling, users, push notifications, etc. To create a QuickBlox application, follow the steps below:

1. Register a new account following this [link](https://admin.quickblox.com/signup). Type in your email and password to sign in. You can also sign in with your Google or Github accounts.
2. Create the app clicking **New app** button.
3. Configure the app. Type in the information about your organization into corresponding fields and click **Add** button.
4. Go to **Dashboard => *YOUR_APP* => Overview** section and copy your **Application ID**,  **Authorization Key**,  **Authorization Secret**,  and **Account Key** .

# Chat Sample

This Sample demonstrates how to work with [Chat](https://docs.quickblox.com/docs/ios-chat) QuickBlox module. 

# Features

It allows to:

1. Login/logout with Quickblox Chat and REST.
2. Receive and display list of dialogs.
3. Modify dialog by adding occupants.
4. Create and leave a 1-to-1 and group chat.
5. Real-time send and receive message/attachment.
6. Display users who have received/read the message.
7. Mark messages as read/delivered.
8. Send typing indicators
9. List and delete chats
10. Display chat history
11. Display a list with chat participants
12. Send/receive push notifications [Push notification](https://docs.quickblox.com/docs/ios-push-notifications) receiving functionality.
13. Subscribe/unsubscribe device to push notifications [Push notification](https://docs.quickblox.com/docs/ios-push-notifications) receiving functionality.

# Views

* Authorization view.
* List of user's dialog.
* Dialog chat view.
* Dialog chat info.
* New dialog view.
* Edit dialog view.

# Run Chat Sample

To run a code sample, follow the steps below:

1. [Get application credentials](#get-application-credentials).
2. Put the received credentials in ```AppDelegate``` file located in the root directory of your project.

```json
Quickblox.initWithApplicationId(92,
                                authKey: "wJHdOcQSxXQGWx5",
                                authSecret: "BTFsj7Rtt27DAmT",
                                accountKey: "7yvNe17TnjNUqDoPwfqp")
```
3. Run the code sample.
