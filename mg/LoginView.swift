//
//  LoginView.swift
//  mg
//
//  Created by Blazej Grzelinski on 07/10/2025.
//

import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var email = Config.defaultEmail
    @State private var password = Config.defaultPassword
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disabled(isLoading)
                
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isLoading)
            }
            .padding(.horizontal, 40)
            
            Button(action: login) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background(isLoading ? Color.gray : Color.blue)
            .cornerRadius(10)
            .padding(.horizontal, 40)
            .disabled(isLoading)
            
            Text("Demo: \(Config.defaultEmail) / \(Config.defaultPassword)")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 10)
        }
        .padding()
        .alert("Login Status", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage.contains("Welcome back") {
                    isLoggedIn = true
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func login() {
        guard !email.isEmpty && !password.isEmpty else {
            alertMessage = "Please enter both email and password"
            showAlert = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let response = try await AuthService.shared.login(email: email, password: password)
                
                await MainActor.run {
                    isLoading = false
                    alertMessage = "Welcome back, \(response.user.name)!"
                    showAlert = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "Login failed: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}
