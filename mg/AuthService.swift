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
        await saveUserSession(loginResponse)
        
        return loginResponse
    }
    
    // MARK: - Logout
    @MainActor
    func logout() {
        DataManager.shared.deleteUserSession()
        print("👋 User logged out")
    }
    
    // MARK: - Session Management
    @MainActor
    func isLoggedIn() -> Bool {
        return DataManager.shared.isUserSessionExists()
    }
    
    @MainActor
    func getAccessToken() -> String? {
        return DataManager.shared.getAccessToken()
    }
    
    @MainActor
    func getRefreshToken() -> String? {
        return DataManager.shared.getRefreshToken()
    }
    
    @MainActor
    func getCurrentUser() -> User? {
        return DataManager.shared.getCurrentUser()
    }
    
    // MARK: - Private Helpers
    @MainActor
    private func saveUserSession(_ response: LoginResponse) {
        DataManager.shared.saveUserSession(
            user: response.user,
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
    }
}

