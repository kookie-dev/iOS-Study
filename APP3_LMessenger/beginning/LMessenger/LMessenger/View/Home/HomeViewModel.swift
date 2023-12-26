//
//  HomeViewModel.swift
//  LMessenger
//
//  Created by Choi Oliver on 12/18/23.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    
    enum Action {
        case load
        case requestContacts
        case presentModal(HomeModalDestination)
        case goToChat(User)
    }
    
    @Published var myUser: User?
    @Published var users: [User] = []
    @Published var phase: Phase = .notRequested
    @Published var modalDestination: HomeModalDestination?
    
    var userId: String
    
    private var container: DIContainable
    private var subscriptions = Set<AnyCancellable>()
    
    init(
        container: DIContainable,
        userId: String
    ) {
        self.container = container
        self.userId = userId
    }
    
    func send(action: Action) {
        switch action {
        case .load:
            phase = .loading
            container.services.userService.getUser(userId: userId)
                .handleEvents(receiveOutput: { [weak self] user in
                    self?.myUser = user
                })
                .flatMap { [weak self] user in
                    self?.container.services.userService.loadUsers(id: user.id)
                    ?? Empty().eraseToAnyPublisher()
                }
                .sink { [weak self] completion in
                    if case .failure = completion {
                        self?.phase = .fail
                    }
                } receiveValue: { [weak self] users in
                    self?.phase = .success
                    self?.users = users
                }.store(in: &subscriptions)
            
        case .requestContacts:
            container.services.contactService.fetchContacts()
                .flatMap { [weak self] users in
                    self?.container.services.userService.addUserAfterContact(users: users)
                    ?? Empty().eraseToAnyPublisher()
                }
                .flatMap { [weak self] _ in
                    guard let self else {
                        return Fail<[User], ServiceError>(error: ServiceError.selfIsNil).eraseToAnyPublisher()
                    }
                    
                    return self.container.services.userService.loadUsers(id: self.userId)
                }
                .sink { [weak self] completion in
                    if case .failure = completion {
                        self?.phase = .fail
                    }
                } receiveValue: { [weak self] users in
                    self?.phase = .success
                    self?.users = users
                }.store(in: &subscriptions)
        
        case let .presentModal(modalDestination):
            self.modalDestination = modalDestination
            
        case let .goToChat(otherUser):
            // ChatRooms/{my user id}/{other user id}
            container.services.chatRoomService.createChatRoomIfNeeded(myUserId: userId, otherUserId: otherUser.id, otherUserName: otherUser.name)
                .sink { completion in
                    
                } receiveValue: { [weak self] chatRoom in
                    guard let self else { return }
                    
                    self.container.navigationRouter.push(
                        to: .chat(
                            chatRoomId: chatRoom.chatRoomId,
                            myUserId: self.userId,
                            otherUserId: otherUser.id
                        )
                    )
                }.store(in: &subscriptions)
            
        } // switch
    }
}
