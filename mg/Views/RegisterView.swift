//
//  RegisterView.swift
//  mg
//
//  Created by Blazej Grzelinski on 17/10/2025.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isLoggedIn: Bool
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.top, 40)
                
                // Registration Form
                VStack(spacing: 20) {
                    // Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter your full name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                    }
                    
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding(.horizontal, 20)
                
                // Register Button
                Button(action: register) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Create Account")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(isFormValid ? Color.blue : Color.gray)
                .cornerRadius(12)
                .disabled(!isFormValid || isLoading)
                .padding(.horizontal, 20)
                
                // Login Link
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.secondary)
                    
                    Button("Sign In") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.medium)
                }
                .font(.body)
                .padding(.top, 20)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Registration", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage.contains("successfully") {
                        isLoggedIn = true
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Form Validation
    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && email.contains("@")
    }
    
    // MARK: - Registration Method
    private func register() {
        guard isFormValid else { return }
        
        isLoading = true
        
        Task {
            do {
                let authService = AuthService.shared;
                _ = try await authService.register(
                    email: email,
                    password: password,
                    name: name
                )
                
                await MainActor.run {
                    isLoading = false
                    alertMessage = "Account created successfully!"
                    showAlert = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "Registration failed: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    RegisterView(isLoggedIn: .constant(false))
}
