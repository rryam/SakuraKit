//
//  SakuraKit.swift
//  SakuraKit 🌸
//
//  Created by Rudrank Riyam on 10/9/24.
//

import Foundation
import os.log

/// A class that manages WebSocket connections to OpenAI's Realtime API.
///
/// `SakuraKit` provides an interface for establishing, managing, and closing WebSocket connections
/// to OpenAI's Realtime API. It handles authentication, connection lifecycle, and logging.
///
/// - Important: This class is designed to be used as an actor to ensure thread-safe access to its properties and methods.
///
/// - Note: The class name "SakuraKit" is inspired by the cherry blossom (桜, sakura), symbolizing beauty and transience in Japanese culture. 🌸
public actor SakuraKit: NSObject {

    /// The active WebSocket task managing the connection.
    private var webSocketTask: URLSessionWebSocketTask?

    /// The API key used for authentication with OpenAI's services.
    private let apiKey: String
    private var socketStream: SocketStream?
    private let logger = Logger(subsystem: "com.example.SakuraKit", category: "WebSocket")

    /// Initializes a new instance of `SakuraKit`.
    ///
    /// - Parameter apiKey: The API key for authenticating with OpenAI's services.
    public init(apiKey: String) {
        self.apiKey = apiKey
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
            URLQueryItem(name: "model", value: "gpt-4o-realtime-preview-2024-10-01")
        ]

        guard let url = urlComponents.url else {
            throw NSError(domain: "SakuraKitError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create URL for WebSocket connection"])
        }

        var request = URLRequest(url: url)
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("realtime=v1", forHTTPHeaderField: "OpenAI-Beta")

        let session = URLSession(configuration: .default)
        let task = session.webSocketTask(with: request)
        self.webSocketTask = task
        self.socketStream = SocketStream(task: task)

        logger.info("WebSocket connection initiated")

        // Send initial ResponseCreateEvent
        try await sendResponseCreateEvent()

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
            logger.error("SocketStream is not initialized")
            return
        }

        do {
            for try await message in stream {
                switch message {
                    case .string(let text):
                        if let data = text.data(using: .utf8),
                           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            logger.info("Received message: \(json)")
                        }
                    case .data(let data):
                        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            logger.info("Received data: \(json)")
                        }
                    @unknown default:
                        logger.error("Unknown message type received")
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
