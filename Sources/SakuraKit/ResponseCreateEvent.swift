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

struct ResponseConfiguration: Encodable {
    let modalities: [String]?
    let instructions: String?
    let voice: String?
    let output_audio_format: String?
    let tools: [Tool]?
    let tool_choice: String?
    let temperature: Double?
    let max_output_tokens: Int?
}