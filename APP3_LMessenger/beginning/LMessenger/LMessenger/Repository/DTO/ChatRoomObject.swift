//
//  ChatRoomObject.swift
//  LMessenger
//
//  Created by Choi Oliver on 12/19/23.
//

import Foundation

struct ChatRoomObject: Codable {
    var chatRoomId: String
    var lastMessage: String?
    var otherUserName: String
    var otherUserId: String
}

extension ChatRoomObject {
    func toModel() -> ChatRoom {
        .init(
            chatRoomId: chatRoomId,
            lastMessage: lastMessage,
            otherUserName: otherUserName,
            otherUserId: otherUserId
        )
    }
}

extension ChatRoomObject {
    static var stub1: ChatRoomObject {
        .init(
            chatRoomId: "chatRoom1_id",
            otherUserName: "user2",
            otherUserId: "user2_id"
        )
    }
}
