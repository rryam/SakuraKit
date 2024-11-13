//
//  PlayAIError.swift
//  SakuraKit
//
//  Created by Rudrank Riyam on 10/15/24.
//

import Foundation

/// An enumeration of errors that can occur during Play.ht API operations.
public enum PlayAIError: Error {
  /// Indicates that the authentication request failed.
  case authenticationFailed
  /// Indicates that the source file URL is invalid.
  case invalidSourceFileURL
  /// Indicates that the user already has an active generation.
  case activeGenerationExists
  /// Indicates that the response from the server was invalid.
  case invalidResponse
  /// Indicates that the server returned an error message.
  case serverError(message: String)
  /// Indicates that the PlayNote generation process failed.
  case generationFailed
}
