//
//  SessionUpdateEvent.swift
//  SakuraKit
//
//  Created by Rudrank Riyam on 10/9/24.
//

import Foundation

struct SessionUpdateEvent: ClientEvent {
    let event_id: String?
    let type: EventType = .sessionUpdate
    let session: SessionConfiguration
}

struct SessionConfiguration: Encodable {
    let modalities: [String]?
    let instructions: String?
    let voice: String?
    let input_audio_format: String?
    let output_audio_format: String?
    let input_audio_transcription: InputAudioTranscription?
    let turn_detection: TurnDetection?
    let tools: [Tool]?
    let tool_choice: String?
    let temperature: Double?
    let max_output_tokens: Int?
}

struct InputAudioTranscription: Encodable {
    let enabled: Bool
    let model: String
}

struct TurnDetection: Encodable {
    let type: String
    let threshold: Double
    let prefix_padding_ms: Int
    let silence_duration_ms: Int
}

struct Tool: Encodable {
    let type: String
    let name: String
    let description: String
    let parameters: ToolParameters
}

struct ToolParameters: Encodable {
    let type: String
    let properties: [String: ToolParameterProperty]
    let required: [String]
}

struct ToolParameterProperty: Encodable {
    let type: String
}
