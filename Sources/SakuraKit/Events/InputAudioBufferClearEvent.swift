//
//  InputAudioBufferClearEvent.swift
//  SakuraKit
//
//  Created by Rudrank Riyam on 10/9/24.
//


struct InputAudioBufferClearEvent: ClientEvent {
    let event_id: String?
    let type: EventType = .inputAudioBufferClear
}