//
//  EventType.swift
//  SakuraKit
//
//  Created by Rudrank Riyam on 10/9/24.
//

enum EventType: String, Encodable {
    case sessionUpdate = "session.update"
    case inputAudioBufferAppend = "input_audio_buffer.append"
    case inputAudioBufferCommit = "input_audio_buffer.commit"
    case inputAudioBufferClear = "input_audio_buffer.clear"
    case conversationItemCreate = "conversation.item.create"
    case conversationItemTruncate = "conversation.item.truncate"
    case conversationItemDelete = "conversation.item.delete"
    case responseCreate = "response.create"
    case responseCancel = "response.cancel"
}
