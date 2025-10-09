//
//  AuthService.swift
//  mg
//
//  Created by Blazej Grzelinski on 09/10/2025.
//

import Foundation

// MARK: - Models
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let message: String
    let user: User
    let accessToken: String
    let refreshToken: String
}

struct User: Codable {
    let id: String
    let email: String
    let name: String
    let avatar: String?
}

// MARK: - Auth Service
class AuthService {
    static let shared = AuthService()
    private let baseURL = Config.baseURL
    
    private init() {}
    
    // MARK: - Login
    func login(email: String, password: String) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/login") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginRequest = LoginRequest(email: email, password: password)
        request.httpBody = try JSONEncoder().encode(loginRequest)
        
        print("🔐 Sending login request to: \(url)")
        print("📧 Email: \(email)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("📡 Response Status Code: \(httpResponse.statusCode)")
        
        // Print raw response data
        if let rawResponse = String(data: data, encoding: .utf8) {
            print("📦 Raw Response Data:")
            print(rawResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorMessage = String(data: data, encoding: .utf8) {
                print("❌ Error Response: \(errorMessage)")
                throw NSError(domain: "AuthError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            }
            throw URLError(.badServerResponse)
        }
        
        // Try to decode with better error handling
        let loginResponse: LoginResponse
        do {
            let decoder = JSONDecoder()
            loginResponse = try decoder.decode(LoginResponse.self, from: data)
        } catch {
            throw error
        }
        
        // Store tokens and user data
        saveUserSession(loginResponse)
        
        return loginResponse
    }
    
    // MARK: - Logout
    func logout() {
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userAvatar")
        
        print("👋 User logged out")
    }
    
    // MARK: - Session Management
    func isLoggedIn() -> Bool {
        return UserDefaults.standard.string(forKey: "accessToken") != nil
    }
    
    func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: "accessToken")
    }
    
    func getRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: "refreshToken")
    }
    
    func getCurrentUser() -> (id: String?, email: String?, name: String?, avatar: String?)? {
        guard isLoggedIn() else { return nil }
        
        return (
            id: UserDefaults.standard.string(forKey: "userId"),
            email: UserDefaults.standard.string(forKey: "userEmail"),
            name: UserDefaults.standard.string(forKey: "userName"),
            avatar: UserDefaults.standard.string(forKey: "userAvatar")
        )
    }
    
    // MARK: - Private Helpers
    private func saveUserSession(_ response: LoginResponse) {
        UserDefaults.standard.set(response.accessToken, forKey: "accessToken")
        UserDefaults.standard.set(response.refreshToken, forKey: "refreshToken")
        UserDefaults.standard.set(response.user.id, forKey: "userId")
        UserDefaults.standard.set(response.user.email, forKey: "userEmail")
        UserDefaults.standard.set(response.user.name, forKey: "userName")
        
        if let avatar = response.user.avatar {
            UserDefaults.standard.set(avatar, forKey: "userAvatar")
        } else {
            UserDefaults.standard.removeObject(forKey: "userAvatar")
        }
        
        print("💾 User session saved")
    }
}

