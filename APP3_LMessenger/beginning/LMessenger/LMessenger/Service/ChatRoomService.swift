//
//  ChatRoomService.swift
//  LMessenger
//
//  Created by Choi Oliver on 12/20/23.
//

import Foundation
import Combine

protocol ChatRoomServiceType {
    func createChatRoomIfNeeded(myUserId: String, otherUserId: String, otherUserName: String) -> AnyPublisher<ChatRoom, ServiceError>
}

class ChatRoomService: ChatRoomServiceType {
    private let dbRepository: ChatRoomDBRepositoryType
    
    init(dbRepository: ChatRoomDBRepositoryType) {
        self.dbRepository = dbRepository
    }
    
    func createChatRoomIfNeeded(myUserId: String, otherUserId: String, otherUserName: String) -> AnyPublisher<ChatRoom, ServiceError> {
        dbRepository.getChatRoom(myUserId: myUserId, otherUserId: otherUserId)
            .mapError { ServiceError.error($0) }
            .flatMap { [weak self] chatRoomObject in
                guard let self else {
                    return Fail<ChatRoom, ServiceError>(error: ServiceError.selfIsNil).eraseToAnyPublisher()
                }
                
                if let chatRoomObject {
                    return Just(chatRoomObject.toModel())
                        .setFailureType(to: ServiceError.self)
                        .eraseToAnyPublisher()
                } else {
                    let newChatRoom: ChatRoom = .init(chatRoomId: UUID().uuidString, otherUserName: otherUserName, otherUserId: otherUserId)
                    return self.addChatRoom(newChatRoom, to: myUserId)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func addChatRoom(_ chatRoom: ChatRoom, to myUserId: String) -> AnyPublisher<ChatRoom, ServiceError> {
        dbRepository.addChatRoom(chatRoom.toObject(), myUserId: myUserId)
            .map { chatRoom }
            .mapError { ServiceError.error($0) }
            .eraseToAnyPublisher()
    }
}

class StubChatRoomService: ChatRoomServiceType {
    
    func createChatRoomIfNeeded(myUserId: String, otherUserId: String, otherUserName: String) -> AnyPublisher<ChatRoom, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
}
