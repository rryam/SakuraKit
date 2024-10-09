//
//  SakuraKit.swift
//  SakuraKit 🌸
//
//  Created by Rudrank Riyam on 10/9/24.
//

import Foundation
import OSLog

public actor SakuraKit: NSObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private let apiKey: String
    private let logger = Logger(subsystem: "com.sakurakit", category: "WebSocket")

    public init(apiKey: String) {
        self.apiKey = apiKey
    }
}

extension SakuraKit {
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

    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        logger.info("WebSocket disconnection initiated")
    }
}

extension SakuraKit: URLSessionWebSocketDelegate {
    nonisolated public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        logger.notice("WebSocket connection opened successfully")
    }

    nonisolated public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        logger.notice("WebSocket connection closed with code: \(closeCode.rawValue)")
        if let reason = reason, let reasonString = String(data: reason, encoding: .utf8) {
            logger.debug("Closure reason: \(reasonString)")
        }
    }
}
