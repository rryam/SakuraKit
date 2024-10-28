//
//  ResponseCancelEvent.swift
//  SakuraKit
//
//  Created by Rudrank Riyam on 10/9/24.
//


struct ResponseCancelEvent: ClientEvent {
    let event_id: String?
    let type: EventType = .responseCancel
}