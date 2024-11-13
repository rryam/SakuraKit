import Foundation

/// A structure representing a PlayNote synthesis request.
public struct PlayNoteRequest {
  /// The URL to the source file.
  public let sourceFileUrl: URL
  /// The synthesis style of the PlayNote.
  public let synthesisStyle: PlayNoteSynthesisStyle
  /// The first voice configuration.
  public let voice1: PlayNoteVoice
  /// The optional second voice configuration.
  public let voice2: PlayNoteVoice?
  
  /// Creates a new PlayNote request.
  /// - Parameters:
  ///   - sourceFileUrl: The URL to the source file.
  ///   - synthesisStyle: The synthesis style to use.
  ///   - voice1: The first voice configuration.
  ///   - voice2: The optional second voice configuration.
  public init(
    sourceFileUrl: URL,
    synthesisStyle: PlayNoteSynthesisStyle,
    voice1: PlayNoteVoice,
    voice2: PlayNoteVoice? = nil
  ) {
    self.sourceFileUrl = sourceFileUrl
    self.synthesisStyle = synthesisStyle
    self.voice1 = voice1
    self.voice2 = voice2
  }
}

/// A structure representing a voice configuration for PlayNote.
public struct PlayNoteVoice {
  /// The ID for a PlayAI Voice.
  public let id: String
  /// The name of the character.
  public let name: String
  /// The gender of the character (optional).
  public let gender: String?
  
  /// Creates a new voice configuration.
  /// - Parameters:
  ///   - id: The voice ID from Play.ai.
  ///   - name: The character name.
  ///   - gender: The optional gender specification.
  public init(id: String, name: String, gender: String? = nil) {
    self.id = id
    self.name = name
    self.gender = gender
  }
}

/// The available synthesis styles for PlayNote.
public enum PlayNoteSynthesisStyle: String, Decodable {
  /// A podcast-style conversation.
  case podcast = "podcast"
  /// An executive briefing style.
  case executiveBriefing = "executive-briefing"
  /// A children's story style.
  case childrensStory = "childrens-story"
  /// A debate style.
  case debate = "debate"
}

/// A structure representing a PlayNote response.
public struct PlayNoteResponse: Decodable {
  /// The unique ID for the PlayNote.
  public let id: String
  /// The owner's ID.
  public let ownerId: String
  /// The name of the PlayNote.
  public let name: String
  /// The source file URL.
  public let sourceFileUrl: String
  /// The generated audio URL.
  public let audioUrl: String?
  /// The synthesis style used.
  public let synthesisStyle: PlayNoteSynthesisStyle
  /// The status of the generation.
  public let status: PlayNoteStatus
  /// The duration in seconds.
  public let duration: Double?
  /// When the PlayNote was requested.
  public let requestedAt: Date
  /// When the PlayNote was created.
  public let createdAt: Date?
  
  /// The current status of the PlayNote.
  public enum PlayNoteStatus: String, Decodable {
    case generating
    case completed
    case failed
  }
} 