//
//  InputAudioBufferAppendEvent.swift
//  SakuraKit
//
//  Created by Rudrank Riyam on 10/9/24.
//


struct InputAudioBufferAppendEvent: ClientEvent {
    let event_id: String?
    let type: EventType = .inputAudioBufferAppend
    let audio: String
}