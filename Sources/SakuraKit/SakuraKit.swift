//
//  SakuraKit.swift
//  SakuraKit 🌸
//
//  Created by Rudrank Riyam on 10/9/24.
//

import Foundation
import OSLog

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
    
    /// A logger instance for recording events and errors.
    private let logger = Logger(subsystem: "com.sakurakit", category: "WebSocket")

    /// Initializes a new instance of `SakuraKit`.
    ///
    /// - Parameter apiKey: The API key for authenticating with OpenAI's services.
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
}

extension SakuraKit {
    
    /// Establishes a WebSocket connection to OpenAI's Realtime API.
    ///
    /// This method constructs the necessary URL and request, including authentication headers,
    /// and initiates the WebSocket connection.
    ///
    /// - Note: If the connection is successful, the `webSocketTask` property will be updated with the new task.
    public func connect() {
        var urlComponents = URLComponents()
        urlComponents.scheme = "wss"
        urlComponents.host = "api.openai.com"
        urlComponents.path = "/v1/realtime"
        urlComponents.queryItems = [
            URLQueryItem(name: "model", value: "gpt-4o-realtime-preview-2024-10-01")
        ]

        guard let url = urlComponents.url else {
            logger.error("Failed to create URL for WebSocket connection")
            return
        }

        var request = URLRequest(url: url)
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("realtime=v1", forHTTPHeaderField: "OpenAI-Beta")

        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()
        logger.info("WebSocket connection initiated")
    }

    /// Closes the active WebSocket connection.
    ///
    /// This method sends a normal closure frame to the server and terminates the connection.
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        logger.info("WebSocket disconnection initiated")
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