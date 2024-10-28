//
//  SakuraKit.swift
//  SakuraKit 🌸
//
//  Created by Rudrank Riyam on 10/9/24.
//

import Foundation
import os.log
import AVFoundation

/// A class that manages WebSocket connections to OpenAI's Realtime API.
///
/// `SakuraKit` provides interfaces for:
/// - Establishing and managing WebSocket connections to OpenAI's Realtime API
/// - Sending and receiving text and audio messages
/// - Handling function calls and responses
/// - Managing conversation state and history
///
/// - Important: This class is designed to be used as an actor to ensure thread-safe access.
public actor SakuraKit: NSObject {

  /// The active WebSocket task managing the connection.
  private var webSocketTask: URLSessionWebSocketTask?

  /// The API key used for authentication with OpenAI's services.
  private let apiKey: String
  private let model: Model
  private var socketStream: SocketStream?
  private let logger = Logger(subsystem: "com.example.SakuraKit", category: "WebSocket")

  /// Initializes a new instance of `SakuraKit`.
  ///
  /// - Parameter apiKey: The API key for authenticating with OpenAI's services.
  public init(apiKey: String, model: Model) {
    self.apiKey = apiKey
    self.model = model
  }

  /// Establishes a WebSocket connection to OpenAI's Realtime API.
  ///
  /// This method constructs the necessary URL and request, including authentication headers,
  /// and initiates the WebSocket connection.
  ///
  /// - Note: If the connection is successful, the `webSocketTask` property will be updated with the new task.
  public func connect() async throws {
    var urlComponents = URLComponents()
    urlComponents.scheme = "wss"
    urlComponents.host = "api.openai.com"
    urlComponents.path = "/v1/realtime"
    urlComponents.queryItems = [
      URLQueryItem(name: "model", value: model.name)
    ]
    
    guard let url = urlComponents.url else {
      throw NSError(domain: "SakuraKitError", code: 0, 
                   userInfo: [NSLocalizedDescriptionKey: "Failed to create URL"])
    }

    var request = URLRequest(url: url)
    request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.addValue("realtime=v1", forHTTPHeaderField: "OpenAI-Beta")

    let session = URLSession(configuration: .default)
    let task = session.webSocketTask(with: request)
    self.webSocketTask = task
    self.socketStream = SocketStream(task: task)

    logger.info("WebSocket connection initiated")
    task.resume()

    // Start receiving messages
    await receiveMessages()
  }

  /// Closes the active WebSocket connection.
  ///
  /// This method sends a normal closure frame to the server and terminates the connection.
  public func disconnect() async throws {
    try await socketStream?.cancel()
    webSocketTask = nil
    socketStream = nil
  }

  /// Receives messages from the WebSocket connection.
  ///
  /// This method continuously receives messages from the WebSocket and processes them.
  private func receiveMessages() async {
    guard let stream = socketStream else {
      logger.error("SocketStream not initialized")
      return
    }

    do {
      for try await message in stream {
        switch message {
        case .string(let text):
          if let data = text.data(using: .utf8),
             let event = try? JSONDecoder().decode(RealtimeServerEvent.self, from: data) {
            await handleServerEvent(event)
          }
        case .data(let data):
          if let event = try? JSONDecoder().decode(RealtimeServerEvent.self, from: data) {
            await handleServerEvent(event)
          }
        @unknown default:
          logger.error("Unknown message type")
        }
      }
    } catch {
      logger.error("Error receiving message: \(error.localizedDescription)")
    }
  }

  /// Sends a ResponseCreateEvent to the WebSocket connection.
  ///
  /// This method constructs a ResponseCreateEvent and sends it to the WebSocket connection.
  public func sendResponseCreateEvent() async throws {
    let event = ResponseCreateEvent(
      event_id: UUID().uuidString,
      response: ResponseConfiguration(
        modalities: ["text"],
        instructions: "Please assist the user."
      )
    )

    let jsonData = try JSONEncoder().encode(event)
    guard let jsonString = String(data: jsonData, encoding: .utf8) else {
      throw NSError(domain: "SakuraKitError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode ResponseCreateEvent"])
    }

    try await webSocketTask?.send(.string(jsonString))
    logger.info("Sent ResponseCreateEvent")
  }

  /// Sends a request to OpenAI's Chat Completions API for text and audio responses.
  ///
  /// This method constructs an HTTP POST request to the Chat Completions API, including the necessary
  /// headers and body parameters for both text and audio responses. It then processes the response,
  /// extracting the text content, audio data, and transcript.
  ///
  /// - Parameters:
  ///   - message: The user's message to be processed by the API.
  ///   - voice: The voice to be used for the audio response (e.g., "alloy").
  ///   - audioFormat: The desired format for the audio response (e.g., "mp3").
  ///
  /// - Returns: A tuple containing the text response and an AudioResponse structure with the audio data and transcript.
  ///
  /// - Throws: An error if the request fails, there's an issue with the response, or audio processing fails.
  public func sendChatCompletionRequest(message: String? = nil, voice: String? = nil, audioFormat: String? = nil) async throws -> (String, AudioResponse) {
    let url = URL(string: "https://api.openai.com/v1/chat/completions")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

    let requestBody: [String: Any] = [
      "model": model.name,
      "modalities": [model.type],
      "audio": ["voice": voice, "format": audioFormat],
      "messages": [
        ["role": "user", "content": message]
      ]
    ]

    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
      throw NSError(domain: "SakuraKitError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
    }

    let jsonResponse = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
    
    guard let audioData = jsonResponse.audio?.data,
          let decodedAudioData = Data(base64Encoded: audioData) else {
      throw NSError(domain: "SakuraKitError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to decode audio data"])
    }
    
    let audioResponse = AudioResponse(
      id: jsonResponse.audio?.id ?? "",
      expiresAt: jsonResponse.audio?.expiresAt ?? 0,
      data: decodedAudioData,
      transcript: jsonResponse.audio?.transcript ?? ""
    )
    
    return (jsonResponse.choices.first?.message.content ?? "", audioResponse)
  }

  /// Sends a text message to the WebSocket connection.
  ///
  /// This method constructs a text message and sends it to the WebSocket connection.
  public func sendTextMessage(_ text: String) async throws {
    let event = RealtimeEvent.conversationItemCreate(
      item: MessageItem(
        type: "message",
        role: "user",
        content: [
          MessageContent(type: "input_text", text: text)
        ]
      )
    )
    
    try await send(event)
    try await createResponse()
  }
  
  /// Sends an audio message to the WebSocket connection.
  ///
  /// This method constructs an audio message and sends it to the WebSocket connection.
  public func sendAudioMessage(_ audioData: Data) async throws {
    let base64Audio = audioData.base64EncodedString()
    
    let event = RealtimeEvent.inputAudioBufferAppend(
      audio: base64Audio
    )
    
    try await send(event)
  }
  
  /// Creates a response to the WebSocket connection.
  ///
  /// This method constructs a response and sends it to the WebSocket connection.
  private func createResponse() async throws {
    let event = RealtimeEvent.responseCreate(
      response: ResponseConfig(
        modalities: ["text", "audio"],
        instructions: "Please assist the user."
      )
    )
    
    try await send(event)
  }
}

// MARK: - Response Models

struct ChatCompletionResponse: Codable {
  let id: String
  let choices: [Choice]
  let audio: AudioResponseData?
}

struct Choice: Codable {
  let message: Message
}

struct Message: Codable {
  let role: String
  let content: String
}

struct AudioResponseData: Codable {
  let id: String
  let expiresAt: Int
  let data: String
  let transcript: String
  
  enum CodingKeys: String, CodingKey {
    case id
    case expiresAt = "expires_at"
    case data
    case transcript
  }
}

public struct AudioResponse {
  public let id: String
  public let expiresAt: Int
  public let data: Data
  public let transcript: String
}

extension SakuraKit: URLSessionWebSocketDelegate {

  /// Called when the WebSocket connection is successfully established.
  ///
  /// - Parameters:
  ///   - session: The `URLSession` instance managing the WebSocket connection.
  ///   - webSocketTask: The `URLSessionWebSocketTask` that was opened.
  ///   - protocol: The subprotocol selected by the server, if any.
  nonisolated public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
    logger.notice("WebSocket connection opened successfully")
  }

  /// Called when the WebSocket connection is closed.
  ///
  /// - Parameters:
  ///   - session: The `URLSession` instance managing the WebSocket connection.
  ///   - webSocketTask: The `URLSessionWebSocketTask` that was closed.
  ///   - closeCode: A code indicating the reason for the closure.
  ///   - reason: Optional data containing a reason for the closure.
  nonisolated public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
    logger.notice("WebSocket connection closed with code: \(closeCode.rawValue)")
    if let reason = reason, let reasonString = String(data: reason, encoding: .utf8) {
      logger.debug("Closure reason: \(reasonString)")
    }
  }
}

public extension SakuraKit {
    enum Model {
        case stable
        case latest
        case audio
        
        var name: String {
            switch self {
            case .latest:
                "gpt-4o-realtime-preview-2024-10-01"
            case .stable:
                "gpt-4o-realtime-preview"
            case .audio:
                "gpt-4o-audio-preview"
            @unknown default:
                "gpt-4o-realtime-preview"
            }
        }
        
        var type: String {
            switch self {
            case .stable:
                "text"
            case .latest:
                "text"
            case .audio:
                "audio"
            }
        }
    }
}
