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
            
            Text("welcome_back".localized)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                TextField("email".localized, text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disabled(isLoading)
                
                
                SecureField("password".localized, text: $password)
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
                    Text("login".localized)
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
            
            Text("demo_credentials".localized(with: Config.defaultEmail, Config.defaultPassword))
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 10)
        }
        .padding()
        .alert("login_failed".localized, isPresented: $showAlert) {
            Button("ok".localized) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func login() {
        guard !email.isEmpty && !password.isEmpty else {
            alertMessage = "please_enter_email_password".localized
            showAlert = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let response = try await AuthService.shared.login(email: email, password: password)
                
                await MainActor.run {
                    isLoading = false
                    // Automatically redirect to home page without showing popup
                    isLoggedIn = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "login_failed".localized + ": \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}
