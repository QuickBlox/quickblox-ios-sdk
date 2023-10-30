<div align="center">

<p>
        <a href="https://discord.gg/Yc56F9KG"><img src="https://img.shields.io/discord/1042743094833065985?color=5865F2&logo=discord&logoColor=white&label=QuickBlox%20Discord%20server&style=for-the-badge" alt="Discord server" /></a>
</p>

</div>

## Overview

QuickBlox iOS Sample UIKit (Swift)

This is a code sample for [QuickBlox](https://quickblox.com) platform. It is a great way for developers using QuickBlox platform to learn how to integrate private and group chat, add text and image attachments sending into your application.

## Get Application Credentials

QuickBlox application includes everything that brings messaging right into your application - chat, video calling, users, push notifications, etc. To create a QuickBlox application, follow the steps below:

1. Register a new account following this [link](https://admin.quickblox.com/signup). Type in your email and password to sign in. You can also sign in with your Google or Github accounts.
2. Create the app clicking **New app** button.
3. Configure the app. Type in the information about your organization into corresponding fields and click **Add** button.
4. Go to **Dashboard => *YOUR_APP* => Overview** section and copy your **Application ID**,  **Authorization Key**,  **Authorization Secret**,  and **Account Key** .

## UIKit Sample

This Sample demonstrates how to work with [UIKit](https://docs.quickblox.com/docs/ios-uikit) QuickBlox module. 

## Features

It allows to:

1. Login/logout with Quickblox Chat and REST.
2. List of dialogs
3. Create dialog(Private or Group)
4. Dialog screen
5. Send text, image, video, audio, file messages
6. Dialog info screen
7. List, invite, remove members

## Run UIKit Sample

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

## AI Features

# QBAIAnswerAssistant

[Video tutorial](https://youtu.be/1HaTipnH2VY)

QBAIAnswerAssistant is a Swift package that helps generate answers in a chat based on the history.

Installation

QBAIAnswerAssistant can be installed using Swift Package Manager. To include it in your Xcode project, follow these steps:

1. In Xcode, open your project, and navigate to File > Swift Packages > Add Package Dependency.
2. Enter the repository URL `https://github.com/QuickBlox/QBAIAnswerAssistant` and click Next.
3. Choose the appropriate version rule and click Next.
4. Finally, click Finish to add the package to your project.

Usage

To use QBAIAnswerAssistant in your project, follow these steps:

1. Import the QBAIAnswerAssistant module:

```swift
import QBAIAnswerAssistant
```

Enable the AI Assist Answer feature:
```swift
QuickBloxUIKit.feature.ai.answerAssist.enable = true
```

If enabled, a button will appear next to each incoming message in the chat interface.

When the button is clicked, the Assist Answer feature will be launched, and a response will be generated based on the chat history.

Set up the AI settings by providing either the OpenAI API key:

```swift
QuickBloxUIKit.feature.ai.answerAssist.apiKey = "YOUR_OPENAI_API_KEY"
```

Or set up with a proxy server:

```swift
QuickBloxUIKit.feature.ai.answerAssist.serverPath = "https://your-proxy-server-url"
```

A developer using the AI Answer Assist library has the ability use to Default AIAnswerAssistSettings.

```swift
public class AIAnswerAssistSettings {
    /// Determines if assist answer functionality is enabled.
    public var enable: Bool = true
    
    /// The OpenAI API key for direct API requests (if not using a proxy server).
    public var apiKey: String = ""
    
    /// The URL path of the proxy server for more secure communication (if not using the API key directly).
    /// [QuickBlox AI Assistant Proxy Server](https://github.com/QuickBlox/qb-ai-assistant-proxy-server).
    public var serverPath: String = ""
    
    /// Represents the available API versions for OpenAI.
    public var apiVersion: QBAIAnswerAssistant.APIVersion = .v1
    
    /// Optional organization information for OpenAI requests.
    public var organization: String? = nil
    
    /// Represents the available GPT models for OpenAI.
    public var model: QBAIAnswerAssistant.Model = .gpt3_5_turbo
    
    /// The temperature setting for generating responses (higher values make output more random).
    public var temperature: Float = 0.5
    
    /// The maximum number of tokens to generate in the request.
    public var maxRequestTokens: Int = 3000
    
    /// The maximum number of tokens to generate in the response.
    public var maxResponseTokens: Int? = nil
}
```

A developer using the AI Answer Assist library has the ability to setup custom settings. This is an example of creating custom tones and installing them in QuickBlox iOS UI Kit from the custom application.

```swift
import QBAIAnswerAssistant

// Setup custom settings for QBAIAnswerAssistant.
QuickBloxUIKit.feature.ai.answerAssist.organization = "CustomDev"
QuickBloxUIKit.feature.ai.answerAssist.model = .gpt4
QuickBloxUIKit.feature.ai.answerAssist.temperature = 0.8
QuickBloxUIKit.feature.ai.answerAssist.maxRequestTokens = 3500
```

A developer using the AI Answer Assist library has the ability to customize the Appearance of UI Answer Assist elements to adapt the user interface to their needs.

```swift
// Default UI Settings for Answer Assist
public struct AIAnswerAssistUISettings {
    public var title: String
    
    public init(_ theme: ThemeProtocol) {
        self.title = theme.string.answerAssistTitle
    }
}
```

This is an example of setting custom settings for the appearance of UI elements from a custom application.

```swift
QuickBloxUIKit.feature.ai.ui.answerAssist.title = "Quick Answer"
More examples of setting custom settings for the appearance of user interface elements from a user application can be found in our UIKitSample.

A developer using the AI Answer Assist library has the ability to customize the Appearance of "Robot" element to adapt the user interface to their needs.

```swift
// Default UI Settings for Robot
public struct AIRobotSettings {
    public var icon: Image
    public var foreground: Color
    public var size: CGSize = CGSize(width: 24.0, height: 24.0)
    public var hidden: Bool = false
    
    public init(_ theme: ThemeProtocol) {
        self.icon = theme.image.robot
        self.foreground = theme.color.mainElements
    }
}
```

This is an example of setting custom settings for the appearance of UI "Robot" element from a custom application.

```swift
QuickBloxUIKit.feature.ai.ui.robot.foreground = .green
QuickBloxUIKit.feature.ai.ui.robot.icon = Image("CustomRobotIcon")
```


# QBAITranslate

QBAITranslate is a Swift package that provides language management and translation functionalities, including integration with the OpenAI API.

## Installation

QBAITranslate can be installed using Swift Package Manager. To include it in your Xcode project, follow these steps:

1. In Xcode, open your project, and navigate to File > Swift Packages > Add Package Dependency.
2. Enter the repository URL `https://github.com/QuickBlox/ios-ai-translate` and click Next.
3. Choose the appropriate version rule and click Next.
4. Finally, click Finish to add the package to your project.

## Usage

To use QBAITranslate in your project, follow these steps:

1. Import the QBAITranslate module:

```swift
import QBAITranslate
```
How to Use

To use the AI Translate feature in your QuickBloxUIKit project, follow these steps:

Enable the AI Translate feature:
```swift
QuickBloxUIKit.feature.ai.translate.enable = true
```
Set up the AI settings by providing either the OpenAI API key:

```swift
QuickBloxUIKit.feature.ai.translate.apiKey = "YOUR_OPENAI_API_KEY"
```

Or set up with a proxy server:

```swift
QuickBloxUIKit.feature.ai.translate.serverPath = "https://your-proxy-server-url"
```
👍
We recommend using a proxy server like the QuickBlox AI Assistant Proxy Server offers significant benefits in terms of security and functionality:

When making direct requests to the OpenAI API from the client-side, sensitive information like API keys may be exposed. By using a proxy server, the API keys are securely stored on the server-side, reducing the risk of unauthorized access or potential breaches.
The proxy server can implement access control mechanisms, ensuring that only authenticated and authorized users with valid QuickBlox user tokens can access the OpenAI API. This adds an extra layer of security to the communication.
A developer using the AI Translate library has the ability use to Default QBAITranslate.Language and Default AITranslateSettings.

```swift
public class AITranslateSettings {
    /// The current `QBAITranslate.Language`.
    ///
    /// Default the same as system language or `.english` if `QBAITranslate.Language` is not support system language.
    public var language: QBAITranslate.Language
  
    /// Determines if assist answer functionality is enabled.
    public var enable: Bool = true
    
    /// The OpenAI API key for direct API requests (if not using a proxy server).
    public var apiKey: String = ""
    
    /// The URL path of the proxy server for more secure communication (if not using the API key directly).
    /// [QuickBlox AI Assistant Proxy Server](https://github.com/QuickBlox/qb-ai-assistant-proxy-server).
    public var serverPath: String = ""
    
    /// Represents the available API versions for OpenAI.
    public var apiVersion: QBAITranslate.APIVersion = .v1
    
    /// Optional organization information for OpenAI requests.
    public var organization: String? = nil
    
    /// Represents the available GPT models for OpenAI.
    public var model: QBAITranslate.Model = .gpt3_5_turbo
    
    /// The temperature setting for generating responses (higher values make output more random).
    public var temperature: Float = 0.5
    
    /// The maximum number of tokens to generate in the request.
    public var maxRequestTokens: Int = 3000
    
    /// The maximum number of tokens to generate in the response.
    public var maxResponseTokens: Int? = nil
}
```

A developer using the AI Translate library has the ability to setup custom translation language (by default used system language). Also a developer has the ability to setup custom settings. This is an example of creating custom tones and installing them in QuickBlox iOS UI Kit from the custom application.

```swift
import QBAITranslate
// Set up the language for translation(by default used system language)
QuickBloxUIKit.feature.ai.translate.language = .spanish

// Setup custom settings for Translate.
QuickBloxUIKit.feature.ai.translate.organization = "CustomDev"
QuickBloxUIKit.feature.ai.translate.model = .gpt4
QuickBloxUIKit.feature.ai.translate.temperature = 0.8
QuickBloxUIKit.feature.ai.translate.maxRequestTokens = 3500
```

A developer using the AI Translate library has the ability to customize the Appearance of UI Translate elements to adapt the user interface to their needs.

```swift
// Default UI Settings for Translate
public struct AITranslateUISettings {
    public var showOriginal: String
    public var showTranslation: String
    public var width: CGFloat
    
    public init(_ theme: ThemeProtocol) {
        self.showOriginal = theme.string.showOriginal
        self.showTranslation = theme.string.showTranslation
        self.width = max(self.showTranslation, self.showOriginal)
            .size(withAttributes: [.font: UIFont.preferredFont(forTextStyle: .caption2)])
            .width + 24.0
    }
}
```

This is an example of setting custom settings for the appearance of UI elements from a custom application.

```swift
QuickBloxUIKit.feature.ai.ui.translate.showOriginal = "Original"
QuickBloxUIKit.feature.ai.ui.translate.showTranslation = "Translation"
```

# QBAIRephrase

QBAIRephrase is a Swift package that provides text rephrasing and tone management functionalities, including integration with the OpenAI API.

## Installation

QBAIRephrase can be installed using Swift Package Manager. To include it in your Xcode project, follow these steps:

1. In Xcode, open your project, and navigate to File > Swift Packages > Add Package Dependency.
2. Enter the repository URL `https://github.com/QuickBlox/ios-ai-rephrase` and click Next.
3. Choose the appropriate version rule and click Next.
4. Finally, click Finish to add the package to your project.

## Usage

To use QBAIRephrase in your project, follow these steps:

1. Import the QBAIRephrase module:

```swift
import QBAIRephrase
```
How to Use

To use the AI Rephrase feature in your QuickBloxUIKit project, follow these steps:

Enable the AI Rephrase feature:
```swift
QuickBloxUIKit.feature.ai.rephrase.enable = true
```

Set up the AI settings by providing either the OpenAI API key:

```swift
QuickBloxUIKit.feature.ai.rephrase.apiKey = "YOUR_OPENAI_API_KEY"
```

Or set up with a proxy server:

```swift
QuickBloxUIKit.feature.ai.rephrase.serverPath = "https://your-proxy-server-url"
```

👍
We recommend using a proxy server like the QuickBlox AI Assistant Proxy Server offers significant benefits in terms of security and functionality:

When making direct requests to the OpenAI API from the client-side, sensitive information like API keys may be exposed. By using a proxy server, the API keys are securely stored on the server-side, reducing the risk of unauthorized access or potential breaches.
The proxy server can implement access control mechanisms, ensuring that only authenticated and authorized users with valid QuickBlox user tokens can access the OpenAI API. This adds an extra layer of security to the communication.
A developer using the AI Rephrase library has the ability use to Default Tones and Default AIRephraseSettings.

```swift
public class AIRephraseSettings {
    public var tones: [QBAIRephrase.AITone] = [
        QBAIRephrase.AITone.professional,
        QBAIRephrase.AITone.friendly,
        QBAIRephrase.AITone.encouraging,
        QBAIRephrase.AITone.empathetic,
        QBAIRephrase.AITone.neutral,
        QBAIRephrase.AITone.assertive,
        QBAIRephrase.AITone.instructive,
        QBAIRephrase.AITone.persuasive,
        QBAIRephrase.AITone.sarcastic,
        QBAIRephrase.AITone.poetic
    ]
  
    /// Determines if assist answer functionality is enabled.
    public var enable: Bool = true
    
    /// The OpenAI API key for direct API requests (if not using a proxy server).
    public var apiKey: String = ""
    
    /// The URL path of the proxy server for more secure communication (if not using the API key directly).
    /// [QuickBlox AI Assistant Proxy Server](https://github.com/QuickBlox/qb-ai-assistant-proxy-server).
    public var serverPath: String = ""
    
    /// Represents the available API versions for OpenAI.
    public var apiVersion: QBAIRephrase.APIVersion = .v1
    
    /// Optional organization information for OpenAI requests.
    public var organization: String? = nil
    
    /// Represents the available GPT models for OpenAI.
    public var model: QBAIRephrase.Model = .gpt3_5_turbo
    
    /// The temperature setting for generating responses (higher values make output more random).
    public var temperature: Float = 0.5
    
    /// The maximum number of tokens to generate in the request.
    public var maxRequestTokens: Int = 3000
    
    /// The maximum number of tokens to generate in the response.
    public var maxResponseTokens: Int? = nil
}
```

A developer using the AI Rephrase library has the ability to delete ringtones, create his own ringtones, and add them to tailor the user interface to his needs. Also a developer has the ability to setup custom settings. This is an example of creating custom tones and installing them in QuickBlox iOS UI Kit from the custom application.

```swift
import QBAIRephrase

// Custom Tones
public extension QBAIRephrase.AITone {
    static let youth = QBAIRephrase.AITone (
        name: "Youth",
        description: "This will allow you to edit messages so that they sound youthful and less formal, using youth slang vocabulary that includes juvenile expressions, unclear sentence structure and without maintaining a formal tone. This will avoid formal speech and ensure appropriate youth greetings and signatures.",
        icon: "🛹"
    )
    
    static let doctor = QBAIRephrase.AITone (
        name: "Doctor",
        description: "This will allow you to edit messages so that they sound doctoral, using medical and medical vocabulary, including professional expressions, unclear sentence structure. This will allow you to make speeches in a medical-doctoral tone and provide appropriate medical greetings and signatures.",
        icon: "🩺"
    )
}

// Array of required tones for your application.
public var customTones: [QBAIRephrase.AITone] = [
    .youth, // Custom Tone
    .doctor, // Custom Tone
    .sarcastic, // Default Tone
    .friendly, // Default Tone
    .empathetic, // Default Tone
    .neutral, // Default Tone
    .poetic // Default Tone
]

// Setup an array of required tones for your application.
QuickBloxUIKit.feature.ai.rephrase.tones = customTones

// Setup custom settings for Rephrase.
QuickBloxUIKit.feature.ai.rephrase.organization = "CustomDev"
QuickBloxUIKit.feature.ai.rephrase.model = .gpt4
QuickBloxUIKit.feature.ai.rephrase.temperature = 0.8
QuickBloxUIKit.feature.ai.rephrase.maxRequestTokens = 3500
```

A developer using the AI Rephrase library has the ability to customize the Appearance of UI Rephrase elements to adapt the user interface to their needs.

```swift
// Default UI Settings for Rephrase
public struct AIRephraseUISettings {
    public var nameForeground: Color
    public var nameFont: Font
    public var iconFont: Font
    public var bubbleBackground: Color
    public var bubbleRadius: CGFloat = 12.5
    public var contentSpacing: CGFloat = 4.0
    public var height: CGFloat = 25.0
    public var buttonHeight: CGFloat = 38.0
    public var contentPadding: EdgeInsets = EdgeInsets(top: 6,
                                                leading: 4,
                                                bottom: 6,
                                                trailing: 4)
    
    public var bubblePadding: EdgeInsets = EdgeInsets(top: 2,
                                                      leading: 8,
                                                      bottom: 2,
                                                      trailing: 8)
    
    public init(_ theme: ThemeProtocol) {
        self.nameForeground = theme.color.mainText
        self.nameFont = theme.font.callout
        self.iconFont = theme.font.caption
        self.bubbleBackground = theme.color.outgoingBackground
    }
}
```

This is an example of setting custom settings for the appearance of UI elements from a custom application.

```swift
QuickBloxUIKit.feature.ai.ui.rephrase.bubbleBackground = .green
QuickBloxUIKit.feature.ai.ui.rephrase.nameForeground = .red
```

## OpenAI

To use the OpenAI API and generate answers, you need to obtain an API key from OpenAI. Follow these steps to get your API key:

1. Go to the [OpenAI website](https://openai.com) and sign in to your account or create a new one.
2. Navigate to the [API](https://platform.openai.com/signup) section and sign up for access to the API.
3. Once approved, you will receive your [API key](https://platform.openai.com/account/api-keys), which you can use to make requests to the OpenAI API.

## Proxy Server

Using a proxy server like the [QuickBlox AI Assistant Proxy Server](https://github.com/QuickBlox/qb-ai-assistant-proxy-server) offers significant benefits in terms of security and functionality:

Enhanced Security:
- When making direct requests to the OpenAI API from the client-side, sensitive information like API keys may be exposed. By using a proxy server, the API keys are securely stored on the server-side, reducing the risk of unauthorized access or potential breaches.
- The proxy server can implement access control mechanisms, ensuring that only authenticated and authorized users with valid QuickBlox user tokens can access the OpenAI API. This adds an extra layer of security to the communication.

Protection of API Keys:
- Exposing API keys on the client-side could lead to misuse, abuse, or accidental exposure. A proxy server hides these keys from the client, mitigating the risk of API key exposure.
- Even if an attacker gains access to the client-side code, they cannot directly obtain the API keys, as they are kept confidential on the server.

Rate Limiting and Throttling:
- The proxy server can enforce rate limiting and throttling to control the number of requests made to the OpenAI API. This helps in complying with API usage policies and prevents excessive usage that might lead to temporary or permanent suspension of API access.

Request Logging and Monitoring:
- By using a proxy server, requests to the OpenAI API can be logged and monitored for auditing and debugging purposes. This provides insights into API usage patterns and helps detect any suspicious activities.

Flexibility and Customization:
- The proxy server acts as an intermediary, allowing developers to introduce custom functionalities, such as response caching, request modification, or adding custom headers. These customizations can be implemented without affecting the client-side code.

SSL/TLS Encryption:
- The proxy server can enforce SSL/TLS encryption for data transmission between the client and the server. This ensures that data remains encrypted and secure during communication.

## License

QBAIAnswerAssistant is released under the [MIT License](LICENSE).

## Contribution

We welcome contributions to improve QBAIAnswerAssistant. If you find any issues or have suggestions, feel free to open an issue or submit a pull request on GitHub.
Join our Discord Server: https://discord.gg/bDyKXGAQRu

Happy coding! 🚀
