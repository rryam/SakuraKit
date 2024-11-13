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

/// An enumeration of available Play.ai voices with their configurations.
public enum PlayNoteVoice {
  case angelo, arsenio, cillian, timo, dexter, miles, briggs
  case deedee, nia, inara, constanza, gideon, casper, mitch, ava
  
  /// The S3 URL for the voice manifest
  public var id: String {
    switch self {
    case .angelo:
      return "s3://voice-cloning-zero-shot/baf1ef41-36b6-428c-9bdf-50ba54682bd8/original/manifest.json"
    case .arsenio:
      return "s3://voice-cloning-zero-shot/65977f5e-a22a-4b36-861b-ecede19bdd65/original/manifest.json"
    case .cillian:
      return "s3://voice-cloning-zero-shot/1591b954-8760-41a9-bc58-9176a68c5726/original/manifest.json"
    case .timo:
      return "s3://voice-cloning-zero-shot/677a4ae3-252f-476e-85ce-eeed68e85951/original/manifest.json"
    case .dexter:
      return "s3://voice-cloning-zero-shot/b27bc13e-996f-4841-b584-4d35801aea98/original/manifest.json"
    case .miles:
      return "s3://voice-cloning-zero-shot/29dd9a52-bd32-4a6e-bff1-bbb98dcc286a/original/manifest.json"
    case .briggs:
      return "s3://voice-cloning-zero-shot/71cdb799-1e03-41c6-8a05-f7cd55134b0b/original/manifest.json"
    case .deedee:
      return "s3://voice-cloning-zero-shot/e040bd1b-f190-4bdb-83f0-75ef85b18f84/original/manifest.json"
    case .nia:
      return "s3://voice-cloning-zero-shot/831bd330-85c6-4333-b2b4-10c476ea3491/original/manifest.json"
    case .inara:
      return "s3://voice-cloning-zero-shot/adb83b67-8d75-48ff-ad4d-a0840d231ef1/original/manifest.json"
    case .constanza:
      return "s3://voice-cloning-zero-shot/b0aca4d7-1738-4848-a80b-307ac44a7298/original/manifest.json"
    case .gideon:
      return "s3://voice-cloning-zero-shot/5a3a1168-7793-4b2c-8f90-aff2b5232131/original/manifest.json"
    case .casper:
      return "s3://voice-cloning-zero-shot/1bbc6986-fadf-4bd8-98aa-b86fed0476e9/original/manifest.json"
    case .mitch:
      return "s3://voice-cloning-zero-shot/c14e50f2-c5e3-47d1-8c45-fa4b67803d19/original/manifest.json"
    case .ava:
      return "s3://voice-cloning-zero-shot/50381567-ff7b-46d2-bfdc-a9584a85e08d/original/manifest.json"
    // case .basil:
    //   return "s3://voice-cloning-zero-shot/different-uuid-needed-here/original/manifest.json" // Need correct UUID
    }
  }
  
  /// The display name of the voice
  public var name: String {
    switch self {
    case .angelo: return "Angelo"
    case .arsenio: return "Arsenio"
    case .cillian: return "Cillian"
    case .timo: return "Timo"
    case .dexter: return "Dexter"
    case .miles: return "Miles"
    case .briggs: return "Briggs"
    case .deedee: return "Deedee"
    case .nia: return "Nia"
    case .inara: return "Inara"
    case .constanza: return "Constanza"
    case .gideon: return "Gideon"
    case .casper: return "Casper"
    case .mitch: return "Mitch"
    case .ava: return "Ava"
   // case .basil: return "Basil"
    }
  }
  
  /// The gender of the voice
  public var gender: String {
    switch self {
    case .deedee, .nia, .inara, .constanza, .ava:
      return "Female"
    default:
      return "Male"
    }
  }
  
  /// The accent of the voice
  public var accent: String {
    switch self {
    case .angelo, .timo, .dexter, .nia, .casper:
      return "US"
    case .arsenio, .miles, .deedee, .inara:
      return "US African American"
    case .cillian:
      return "Irish"
    case .briggs:
      return "US Southern (Oklahoma)"
    case .constanza:
      return "US Latin American"
    case .gideon:
      return "British"
    case .mitch, .ava:
      return "Australian"
    // case .basil:
    //   return "British (Yorkshire)"
    }
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