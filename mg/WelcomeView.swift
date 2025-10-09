//
//  WelcomeView.swift
//  mg
//
//  Created by Blazej Grzelinski on 07/10/2025.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var isLoggedIn: Bool
    @State private var userName: String = ""
    @State private var userEmail: String = ""
    @State private var userAvatar: String = ""
    
    var body: some View {
        VStack(spacing: 30) {
            // Header with logout button
            HStack {
                Spacer()
                Button("Logout") {
                    AuthService.shared.logout()
                    isLoggedIn = false
                }
                .foregroundColor(.red)
                .padding()
            }
            
            // Welcome content
            VStack(spacing: 20) {
                // User Avatar
                AsyncImage(url: URL(string: userAvatar)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                }
                
                Text("Welcome, \(userName)!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("You have successfully logged in to your account.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)
                
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                        Text("Name: \(userName)")
                            .font(.headline)
                    }
                    
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.purple)
                        Text("Email: \(userEmail)")
                            .font(.headline)
                    }
                    
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.orange)
                        Text("Login Time: \(getCurrentTime())")
                            .font(.headline)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal, 40)
                
                // Map Button
                NavigationLink(destination: MapView()) {
                    HStack {
                        Image(systemName: "map.fill")
                            .foregroundColor(.white)
                        Text("View Map")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // Footer
            Text("Thank you for using our app!")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
        }
        .padding()
        .navigationBarHidden(true)
        .onAppear {
            loadUserData()
        }
    }
    
    private func loadUserData() {
        userName = UserDefaults.standard.string(forKey: "userName") ?? "User"
        userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? "user@example.com"
        userAvatar = UserDefaults.standard.string(forKey: "userAvatar") ?? ""
    }
    
    private func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}

#Preview {
    WelcomeView(isLoggedIn: .constant(true))
}
