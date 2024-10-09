//
//  ConversationItemTruncateEvent.swift
//  SakuraKit
//
//  Created by Rudrank Riyam on 10/9/24.
//


struct ConversationItemTruncateEvent: ClientEvent {
    let event_id: String?
    let type: EventType = .conversationItemTruncate
    let item_id: String
    let content_index: Int
    let audio_end_ms: Int
}