//
//  InputAudioBufferCommitEvent.swift
//  SakuraKit
//
//  Created by Rudrank Riyam on 10/9/24.
//


struct InputAudioBufferCommitEvent: ClientEvent {
    let event_id: String?
    let type: EventType = .inputAudioBufferCommit
}