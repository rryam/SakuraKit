# SakuraKit: Swift SDK to Quickly Prototype OpenAI Realtime API

SakuraKit is a Swift SDK designed to quickly prototype with the OpenAI Realtime API to build low-latency, multimodal experiences with ease. 

This SDK is named after the cherry blossoms (Sakura) to enjoy in Shibuya next year. 🌸

## Installation

To get started with SakuraKit, add it to your Swift project using Swift Package Manager (SPM):

```swift
dependencies: [
    .package(url: "https://github.com/rryam/SakuraKit", from: "1.0.0")
]
```

Then, import it into your project:

```swift
import SakuraKit
```

## Getting Started

### Prerequisites
- OpenAI API Key: You will need a valid API key from OpenAI.

## Basic Usage

Here is a quick example to get you started:

```swift
import SakuraKit

// Initialize the SakuraKit client
let sakuraKit = SakuraKit(apiKey: "your_openai_api_key")

// Connect to the Realtime API with a WebSocket
```

## Contributing

I welcome contributions! Feel free to open issues or submit pull requests to help improve SakuraKit.

## License

SakuraKit is licensed under the MIT License. See LICENSE for more details.
