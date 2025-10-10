//
//  DataManager.swift
//  mg
//
//  Created by Blazej Grzelinski on 09/10/2025.
//

import Foundation
import SwiftData

@MainActor
class DataManager {
    static let shared = DataManager()
    
    let container: ModelContainer
    var context: ModelContext {
        container.mainContext
    }
    
    private init() {
        do {
            let schema = Schema([UserSessionModel.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    // MARK: - User Session Management
    func saveUserSession(user: User, accessToken: String, refreshToken: String) {
        // Delete existing session first
        deleteUserSession()
        
        let session = UserSessionModel(
            id: user.id,
            email: user.email,
            name: user.name,
            avatar: user.avatar,
            accessToken: accessToken,
            refreshToken: refreshToken
        )
        
        context.insert(session)
        
        do {
            try context.save()
            print("💾 User session saved to SwiftData")
        } catch {
            print("❌ Error saving user session: \(error)")
        }
    }
    
    func getUserSession() -> (user: User, accessToken: String, refreshToken: String)? {
        let descriptor = FetchDescriptor<UserSessionModel>()
        
        do {
            let sessions = try context.fetch(descriptor)
            guard let session = sessions.first else {
                return nil
            }
            
            return (
                user: session.toUser(),
                accessToken: session.accessToken,
                refreshToken: session.refreshToken
            )
        } catch {
            print("❌ Error fetching user session: \(error)")
            return nil
        }
    }
    
    func deleteUserSession() {
        let descriptor = FetchDescriptor<UserSessionModel>()
        
        do {
            let sessions = try context.fetch(descriptor)
            for session in sessions {
                context.delete(session)
            }
            try context.save()
            print("🗑️ User session deleted from SwiftData")
        } catch {
            print("❌ Error deleting user session: \(error)")
        }
    }
    
    func isUserSessionExists() -> Bool {
        let descriptor = FetchDescriptor<UserSessionModel>()
        
        do {
            let count = try context.fetchCount(descriptor)
            return count > 0
        } catch {
            print("❌ Error checking user session: \(error)")
            return false
        }
    }
    
    func getAccessToken() -> String? {
        return getUserSession()?.accessToken
    }
    
    func getRefreshToken() -> String? {
        return getUserSession()?.refreshToken
    }
    
    func getCurrentUser() -> User? {
        return getUserSession()?.user
    }
}

