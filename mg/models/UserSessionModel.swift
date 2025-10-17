//
//  UserSessionModel.swift
//  mg
//
//  Created by Blazej Grzelinski on 09/10/2025.
//

import Foundation
import SwiftData

@Model
final class UserSessionModel {
    @Attribute(.unique) var id: String
    var email: String
    var name: String
    var avatar: String?
    var accessToken: String
    var refreshToken: String
    var createdAt: Date
    
    init(id: String, email: String, name: String, avatar: String?, accessToken: String, refreshToken: String) {
        self.id = id
        self.email = email
        self.name = name
        self.avatar = avatar
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.createdAt = Date()
    }
    
    // Convert to User model
    func toUser() -> User {
        return User(id: id, email: email, name: name, avatar: avatar)
    }
}

