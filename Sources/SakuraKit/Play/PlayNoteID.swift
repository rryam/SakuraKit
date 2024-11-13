/// An object that represents a unique identifier for a Play.ht note.
///
/// Use `PlayNoteID` to identify and reference specific Play.ht notes within your app.
/// This identifier is unique across all Play.ht notes and can be used to fetch, track,
/// or manage individual notes.
///
/// You can create a `PlayNoteID` in several ways:
/// ```swift
/// // Using string literal
/// let id1: PlayNoteID = "note_123456"
///
/// // Using initializer
/// let id2 = PlayNoteID("note_123456")
///
/// // Using raw value initializer
/// let id3 = PlayNoteID(rawValue: "note_123456")
/// ```
public struct PlayNoteID: Equatable, Hashable, Sendable, RawRepresentable, ExpressibleByStringLiteral {
  
  /// The raw string value of the Play.ht note identifier.
  public let rawValue: String
  
  /// Creates a Play.ht note identifier with a string.
  ///
  /// - Parameter rawValue: The string value representing the note identifier.
  public init(_ rawValue: String) {
    self.rawValue = rawValue
  }
  
  /// Creates a new instance with the specified raw value.
  ///
  /// - Parameter rawValue: The raw string value to use for the new instance.
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
  
  /// Creates an instance initialized to the given string value.
  ///
  /// - Parameter value: The string value to use for the new instance.
  public init(stringLiteral value: String) {
    self.rawValue = value
  }
  
  // Type aliases for protocol conformance
  public typealias StringLiteralType = String
  public typealias ExtendedGraphemeClusterLiteralType = String
  public typealias UnicodeScalarLiteralType = String
}

extension PlayNoteID: Codable {
  
  /// Creates a new instance by decoding from the given decoder.
  ///
  /// - Parameter decoder: The decoder to read data from.
  /// - Throws: An error if reading from the decoder fails.
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.rawValue = try container.decode(String.self)
  }
  
  /// Encodes this value into the given encoder.
  ///
  /// - Parameter encoder: The encoder to write data to.
  /// - Throws: An error if encoding fails.
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }
}

extension PlayNoteID: CustomStringConvertible {
  
  /// A textual representation of the Play.ht note identifier.
  ///
  /// This property returns the raw string value of the identifier.
  public var description: String {
    return rawValue
  }
} 