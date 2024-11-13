//
//  ResponseCreateEvent.swift
//  SakuraKit
//
//  Created by Rudrank Riyam on 10/9/24.
//


struct ResponseCreateEvent: ClientEvent {
    let event_id: String?
    let type: EventType = .responseCreate
    let response: ResponseConfiguration
}

public struct ResponseConfiguration: Encodable {
    let modalities: [String]?
    let instructions: String?
    let voice: String?
    let output_audio_format: String?
    let tools: [Tool]?
    let tool_choice: String?
    let temperature: Double
    let max_output_tokens: Int?

    public init(modalities: [String]?, instructions: String?, voice: String? = nil, output_audio_format: String? = nil, tools: [Tool]? = nil, tool_choice: String? = nil, temperature: Double = 1.0, max_output_tokens: Int? = nil) {
        self.modalities = modalities
        self.instructions = instructions
        self.voice = voice
        self.output_audio_format = output_audio_format
        self.tools = tools
        self.tool_choice = tool_choice
        self.temperature = temperature
        self.max_output_tokens = max_output_tokens
    }
}
