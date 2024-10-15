//
//  PlayAI.swift
//  SakuraKit
//
//  Created by Rudrank Riyam on 10/15/24.
//

import Foundation

/// An actor that manages authentication and WebSocket connections for the Play.ht API.
///
/// `PlayAI` provides an interface for authenticating with the Play.ht API, obtaining
/// a WebSocket URL for real-time communication, and sending TTS commands. It encapsulates
/// the API key and user ID, ensuring secure and thread-safe access to these credentials.
///
/// - Important: This class is designed as an actor to ensure thread-safe access to its properties and methods.
public actor PlayAI {
  
  /// The API key used for authentication with Play.ht services.
  private let apiKey: String
  
  /// The user ID associated with the Play.ht account.
  private let userId: String
  
  /// The URL for the WebSocket authentication endpoint.
  private let authEndpoint = URL(string: "https://api.play.ht/api/v3/websocket-auth")!
  
  /// Initializes a new instance of `PlayAI`.
  ///
  /// - Parameters:
  ///   - apiKey: The API key for authenticating with Play.ht services.
  ///   - userId: The user ID associated with the Play.ht account.
  public init(apiKey: String, userId: String) {
    self.apiKey = apiKey
    self.userId = userId
  }
  
  /// Authenticates with the Play.ht API and retrieves a WebSocket URL.
  ///
  /// This method sends an authenticated POST request to the Play.ht WebSocket
  /// authentication endpoint using the stored API key and user ID. It then parses
  /// the response to extract the WebSocket URL for establishing a real-time connection.
  ///
  /// - Returns: A string containing the authenticated WebSocket URL for establishing a connection.
  /// - Throws: An error if the authentication request fails or if the response cannot be parsed.
  public func authenticateAndFetchWebSocketURL() async throws -> String {
    var request = URLRequest(url: authEndpoint)
    request.httpMethod = "POST"
    request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.addValue(userId, forHTTPHeaderField: "X-User-Id")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
      throw PlayAIError.authenticationFailed
    }
    
    let decoder = JSONDecoder()
    let authResponse = try decoder.decode(PlayAIWebSocketAuthResponse.self, from: data)
    
    return authResponse.websocketURL
  }
  
  /// Sends a Text-to-Speech (TTS) command to the Play.ht WebSocket API.
  ///
  /// This method establishes a WebSocket connection using the provided URL,
  /// constructs a JSON message containing TTS parameters, and sends it through
  /// the WebSocket connection.
  ///
  /// - Parameters:
  ///   - url: The WebSocket URL to connect to.
  ///   - text: The text to be converted to speech.
  ///   - voice: The voice ID or URL to use for synthesis.
  ///   - outputFormat: The desired audio format (default is "mp3").
  ///   - quality: The quality of the audio ("draft", "standard", or "premium").
  ///   - temperature: Controls the randomness of the generated speech (0.0 to 1.0).
  ///   - speed: The speed of the generated speech (0.5 to 2.0).
  ///   - requestId: A unique identifier for the request (optional).
  ///
  /// - Throws: An error if the WebSocket connection fails, JSON encoding fails, or if there's an issue sending the message.
  public func sendTTSCommand(
    to url: URL,
    text: String,
    voice: String,
    outputFormat: String = "mp3",
    quality: String? = nil,
    temperature: Double? = nil,
    speed: Double? = nil,
    requestId: String? = nil
  ) async throws {
    let session = URLSession(configuration: .default)
    let webSocketTask = session.webSocketTask(with: url)
    
    try await webSocketTask.resume()
    
    let ttsCommand: [String: Any] = [
      "text": text,
      "voice": voice,
      "output_format": outputFormat,
      "quality": quality,
      "temperature": temperature,
      "speed": speed,
      "request_id": requestId
    ].compactMapValues { $0 }
    
    let jsonData = try JSONSerialization.data(withJSONObject: ttsCommand)
    let jsonString = String(data: jsonData, encoding: .utf8)!
    
    try await webSocketTask.send(.string(jsonString))
  }
  /// Receives and processes messages from the WebSocket connection using an async stream.
  ///
  /// This method creates an async stream of messages from the WebSocket, handling both audio data
  /// and end-of-stream messages. It collects audio chunks and provides the complete audio data
  /// when the stream is finished.
  ///
  /// - Parameters:
  ///   - webSocketTask: The URLSessionWebSocketTask instance representing the active WebSocket connection.
  ///
  /// - Returns: An AsyncThrowingStream that yields audio data when it's complete.
  ///
  /// - Throws: An error if there's an issue receiving or processing messages.
  private func receiveMessages(from webSocketTask: URLSessionWebSocketTask) -> AsyncThrowingStream<Data, Error> {
    AsyncThrowingStream { continuation in
      Task {
        var audioChunks: [Data] = []
        
        do {
          while true {
            let message = try await webSocketTask.receive()
            switch message {
            case .string(let text):
              if let data = text.data(using: .utf8),
                 let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                 json.keys.contains("request_id") {
                // End of audio stream
                let audioData = audioChunks.reduce(Data(), +)
                continuation.yield(audioData)
                audioChunks.removeAll()
              } else {
                print("Received unexpected text message: \(text)")
              }
            case .data(let data):
              // Received binary audio data
              audioChunks.append(data)
            @unknown default:
              print("Received unknown message type")
            }
          }
        } catch {
          continuation.finish(throwing: error)
        }
        
        continuation.finish()
      }
    }
  }
  
  /// Handles WebSocket errors and connection closures.
  ///
  /// This method sets up error and closure handlers for the WebSocket connection.
  ///
  /// - Parameter webSocketTask: The URLSessionWebSocketTask instance to monitor.
  private func handleWebSocketEvents(for webSocketTask: URLSessionWebSocketTask) {
    webSocketTask.observe(\.state) { task, _ in
      if task.state == .completed {
        if let error = task.error {
          print("WebSocket Error: \(error.localizedDescription)")
        } else {
          print("WebSocket connection closed")
        }
        // Implement reconnection logic if needed
      }
    }
  }
  
  /// Processes the audio stream from the WebSocket connection.
  ///
  /// This method demonstrates how to use the `receiveMessages` function with an async stream.
  ///
  /// - Parameter webSocketTask: The URLSessionWebSocketTask instance representing the active WebSocket connection.
  ///
  /// - Throws: An error if there's an issue processing the audio stream.
  public func processAudioStream(from webSocketTask: URLSessionWebSocketTask) async throws {
    let audioStream = receiveMessages(from: webSocketTask)
    
    for try await audioData in audioStream {
      // Here you can handle the complete audio data
      // For example, you might want to play it, save it, or process it further
      print("Received complete audio data of size: \(audioData.count) bytes")
      
      // Example: Save the audio data to a file
      let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      let audioFileURL = documentsPath.appendingPathComponent("audio_\(Date().timeIntervalSince1970).mp3")
      try audioData.write(to: audioFileURL)
      print("Audio saved to: \(audioFileURL.path)")
    }
  }
}
