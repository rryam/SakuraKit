//
//  ClientEvent.swift
//  SakuraKit
//
//  Created by Rudrank Riyam on 10/9/24.
//

import Foundation

protocol ClientEvent: Encodable {
    var event_id: String? { get }
    var type: EventType { get }
}
