//
//  ConversationItemDeleteEvent.swift
//  SakuraKit
//
//  Created by Rudrank Riyam on 10/9/24.
//


struct ConversationItemDeleteEvent: ClientEvent {
    let event_id: String?
    let type: EventType = .conversationItemDelete
    let item_id: String
}