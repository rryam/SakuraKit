# SakuraKit: Swift SDK for Prototyping AI Speech Generation

SakuraKit is a Swift SDK designed to quickly prototyping speech-to-speech or text-to-speech using different APIs to build low-latency, multimodal experiences with ease. 

This SDK is named after the cherry blossoms (Sakura) to enjoy in Shibuya next year. 🌸

## Support

Love this project? Check out my books to explore more of AI and iOS development:
- [Exploring AI for iOS Development](https://academy.rudrank.com/product/ai)
- [Exploring AI-Assisted Coding for iOS Development](https://academy.rudrank.com/product/ai-assisted-coding)

Your support helps to keep this project growing!

## Installation

To get started with SakuraKit, add it to your Swift project using Swift Package Manager (SPM):

```swift
dependencies: [
    .package(url: "https://github.com/rryam/SakuraKit", from: "0.1.0")
]
```

Then, import it into your project:

```swift
import SakuraKit
```

## Getting Started

### Prerequisites
- Play.ht API Key and User ID: Required for text-to-speech functionality.

## Basic Usage

### Play.ht Text-to-Speech

Initialize the Play.ht client:

## Basic Usage

Here is a quick example to get you started:

```swift
import SakuraKit

// Initialize the SakuraKit client
let playAI = PlayAI(apiKey: "your_playht_api_key", userId: "your_user_id")

// Create a PlayNote for generating audio from PDF:
let request = PlayNoteRequest(
sourceFileUrl: sourceURL,
synthesisStyle: .podcast,
voice1: .angelo,
voice2: .nia
)

let response = try await playAI.createPlayNote(request)
```

Available voice styles include:
- Podcast conversations
- Executive briefings
- Children's stories
- Debates

## Contributing

I welcome contributions! Feel free to open issues or submit pull requests to help improve SakuraKit.

## License

SakuraKit is licensed under the MIT License. See LICENSE for more details.
