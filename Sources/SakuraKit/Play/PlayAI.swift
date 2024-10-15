//
//  PlayAI.swift
//  SakuraKit
//
//  Created by Rudrank Riyam on 10/15/24.
//

import Foundation

/// An actor that manages authentication and WebSocket connections for the Play.ht API.
///
/// `PlayAI` provides an interface for authenticating with the Play.ht API and obtaining
/// a WebSocket URL for real-time communication. It encapsulates the API key and user ID,
/// ensuring secure and thread-safe access to these credentials.
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
}
