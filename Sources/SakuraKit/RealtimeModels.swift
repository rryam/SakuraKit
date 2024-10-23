import Foundation

// Client Events
enum RealtimeEvent: Encodable {
  case sessionUpdate(config: SessionConfig)
  case conversationItemCreate(item: MessageItem)
  case inputAudioBufferAppend(audio: String)
  case responseCreate(response: ResponseConfig)
  case responseCancel
  
  var type: String {
    switch self {
    case .sessionUpdate: return "session.update"
    case .conversationItemCreate: return "conversation.item.create"
    case .inputAudioBufferAppend: return "input_audio_buffer.append"
    case .responseCreate: return "response.create"
    case .responseCancel: return "response.cancel"
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(type, forKey: .type)
    
    switch self {
    case .sessionUpdate(let config):
      try container.encode(config, forKey: .config)
    case .conversationItemCreate(let item):
      try container.encode(item, forKey: .item)
    case .inputAudioBufferAppend(let audio):
      try container.encode(audio, forKey: .audio)
    case .responseCreate(let response):
      try container.encode(response, forKey: .response)
    case .responseCancel:
      break
    }
  }
  
  private enum CodingKeys: String, CodingKey {
    case type, config, item, audio, response
  }
}

// Server Events
enum RealtimeServerEvent: Decodable {
  case sessionCreated(SessionInfo)
  case conversationCreated(ConversationInfo)
  case responseContentPartAdded(ContentPart)
  case error(ErrorInfo)
  // Add other event cases as needed
}

// Supporting Models
struct SessionConfig: Codable {
  let voice: String?
  let inputAudioTranscription: Bool?
  let tools: [Tool]?
}

struct MessageItem: Codable {
  let type: String
  let role: String
  let content: [MessageContent]
}

struct MessageContent: Codable {
  let type: String
  let text: String?
  let audio: String?
}

struct ResponseConfig: Codable {
  let modalities: [String]
  let instructions: String
}

struct SessionInfo: Codable {
  let id: String
  let object: String
  let model: String
}

struct ConversationInfo: Codable {
  let id: String
  let object: String
}

struct ContentPart: Codable {
  let type: String
  let text: String?
  let audio: String?
}

struct ErrorInfo: Codable {
  let code: String
  let message: String
}

struct Tool: Codable {
  let name: String
  let description: String
  let parameters: [String: Any]
  
  private enum CodingKeys: String, CodingKey {
    case name, description, parameters
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(description, forKey: .description)
    try container.encode(parameters, forKey: .parameters)
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)
    description = try container.decode(String.self, forKey: .description)
    parameters = try container.decode([String: Any].self, forKey: .parameters)
  }
}
