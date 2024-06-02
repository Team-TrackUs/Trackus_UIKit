//
//  ChatManager.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/30/24.
//

import Foundation
import Firebase
import FirebaseFirestore

class ChatRoomManager {
    static let shared = ChatRoomManager()
    
    var chatRooms: [Chat] = []
    var userInfo: [String: User] = [:]
    
    
    
    private let ref = Firestore.firestore().collection("chats")
    
    func dummyData() {
        let dummyChats: [Chat] = [
            Chat(
                uid: "chat1",
                group: false,
                title: "",
                members: [User.currentUid: true, "user2": true],
                usersUnreadCountInfo: ["user1": 0, User.currentUid: 6],
                latestMessage: LastetMessage(timestamp: Date(), text: "Hey Alice!"),
                toUser: "user2",
                fromUser: "user1"
            ),
            Chat(
                uid: "chat2",
                group: true,
                title: "그룹채팅 (3명)",
                members: [User.currentUid: true,"user1": true, "user3": true, "user4": true],
                usersUnreadCountInfo: [User.currentUid: 6, "user1": 2, "user3": 0, "user4": 1],
                latestMessage: LastetMessage(timestamp: Date(), text: "Next meeting at 5 PM."),
                toUser: nil,
                fromUser: nil
            ),
            Chat(
                uid: "chat3",
                group: false,
                title: "",
                members: ["user1": true, User.currentUid: true],
                usersUnreadCountInfo: [User.currentUid: 1, "user5": 0],
                latestMessage: LastetMessage(timestamp: Date(), text: "See you tomorrow!"),
                toUser: "user5",
                fromUser: "user1"
            ),
            Chat(
                uid: "chat4",
                group: true,
                title: "그룹 더미 2(3명, 나간사람 1)",
                members: [User.currentUid: true, "user1": true, "user2": true, "user3": false],
                usersUnreadCountInfo: [User.currentUid: 0, "user1": 0, "user2": 3],
                toUser: nil,
                fromUser: nil
            )
        ]
        self.chatRooms = dummyChats
        var user1 = User()
        user1.uid = "user1"
        user1.name = "유저1"
        user1.profileImageUrl = "https://firebasestorage.googleapis.com:443/v0/b/newtrackus.appspot.com/o/usersImage%2FJJMVcgVXYNUMDIs9N8hXoiaiXAm1?alt=media&token=b1a4c6c0-4cfe-4fa7-9f98-89580c1137ce"
        var user2 = User()
        user2.uid = "user2"
        user2.name = "유저2"
        var user3 = User()
        user3.uid = "user3"
        user3.name = "유저3"
        var user4 = User()
        user4.uid = "user4"
        user4.name = "유저4"
        var user5 = User()
        user5.uid = "user5"
        user5.name = "유저5"
        
        let dummyUsers: [String: User] = [
            "user1": user1,
            "user2": user2,
            "user3": user3,
            "user4": user4,
            "user5": user5,
        ]
        self.userInfo = dummyUsers
    }
    // MARK: - 채팅방 리스너 관련
    // 채팅방 listener 추가
    func subscribeToUpdates() {
        let currentUid = User.currentUid
        ref.whereField("members", arrayContains: currentUid).addSnapshotListener() { [weak self] (snapshot, _) in
            self?.storeChatRooms(snapshot, currentUid)
        }
    }
    
    // 채팅방 Firebase 정보 가져오기
    private func storeChatRooms(_ snapshot: QuerySnapshot?, _ currentUId: String) {
        DispatchQueue.main.async { [weak self] in
            self?.chatRooms = snapshot?.documents
                .compactMap { [weak self] document in
                    do {
                        let firestoreChatRoom = try document.data(as: FirestoreChatRoom.self)
                        return self?.makeChatRooms(firestoreChatRoom, currentUId)
                    } catch {
                        print(error)
                    }

                    return nil
                }.sorted {
                    if let date1 = $0.latestMessage?.timestamp, let date2 = $1.latestMessage?.timestamp {
                        return date1 > date2
                    }
                    return $0.title < $1.title
                }
            ?? []
        }
    }
    
    // ChatRoom타입에 맞게 변환
    private func makeChatRooms(_ firestoreChatRoom: FirestoreChatRoom, _ currentUId: String) -> Chat {
        var message: LastetMessage? = nil
        if let flm = firestoreChatRoom.latestMessage {
            message = LastetMessage(
                //senderName: user.name,
                timestamp: flm.timestamp,
                text: flm.text.isEmpty ? "사진을 보냈습니다." : flm.text
            )
        }
        let members = firestoreChatRoom.members
        _ = firestoreChatRoom.members.map { memberId in
            memberUserInfo(uid: memberId.key)
        }
        let chatRoom = Chat(
            uid: firestoreChatRoom.id ?? "",
            group: firestoreChatRoom.group,
            title: firestoreChatRoom.title,
            members: firestoreChatRoom.members,
            usersUnreadCountInfo: firestoreChatRoom.usersUnreadCountInfo,
            latestMessage: message
        )
        return chatRoom
    }
    
    // 채팅방 멤버 닉네임, 프로필사진url 불러오기
    private func memberUserInfo(uid: String) {
        Firestore.firestore().collection("users").document(uid).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                // 탈퇴 사용자인 경우 리스트에서 삭제
                self.chatRooms = self.chatRooms.map{
                    var chatRomm = $0
                    chatRomm.members = $0.members.filter{ $0.key != uid }
                    return chatRomm
                }
                return
            }
            do {
                var userInfo = try document.data(as: User.self)
//                if userInfo.isBlock {
//                    userInfo.username = "정지 회원"
//                    userInfo.profileImageUrl = nil
//                    userInfo.token = nil
//                }
                self.userInfo[uid] = userInfo
            } catch {
                print("Error decoding document: \(error)")
            }
        }
    }
    
}
