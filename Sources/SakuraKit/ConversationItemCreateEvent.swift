//
//  ConversationItemCreateEvent.swift
//  SakuraKit
//
//  Created by Rudrank Riyam on 10/9/24.
//


struct ConversationItemCreateEvent: ClientEvent {
    let event_id: String?
    let type: EventType = .conversationItemCreate
    let previous_item_id: String?
    let item: ConversationItem
}

struct ConversationItem: Encodable {
    let id: String?
    let type: String
    let status: String?
    let role: String
    let content: [ContentPart]
}

struct ContentPart: Encodable {
    let type: String
    let text: String?
    let audio: String?
}