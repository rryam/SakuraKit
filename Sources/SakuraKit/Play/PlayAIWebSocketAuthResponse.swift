//
//  PlayAIWebSocketAuthResponse.swift
//  SakuraKit
//
//  Created by Rudrank Riyam on 10/15/24.
//

import Foundation

/// A structure representing the response from the WebSocket authentication endpoint.
public struct PlayAIWebSocketAuthResponse: Codable {
  /// The WebSocket URL to be used for establishing a connection.
  let websocketURL: String
  
  enum CodingKeys: String, CodingKey {
    case websocketURL = "websocket_url"
  }
}
