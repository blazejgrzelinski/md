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
    @StateObject private var locationManager = LocationManager.shared
    @State private var showLocationPermission = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Header with logout button
            HStack {
                Spacer()
                Button("logout".localized) {
                    Task { @MainActor in
                        AuthService.shared.logout()
                        isLoggedIn = false
                    }
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
                
                Text("welcome_user".localized(with: userName))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("successfully_logged_in".localized)
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
                        Text("login_time".localized + ": \(getCurrentTime())")
                            .font(.headline)
                    }
                    
                    HStack {
                        Image(systemName: locationManager.isLocationEnabled ? "location.fill" : "location.slash")
                            .foregroundColor(locationManager.isLocationEnabled ? .green : .red)
                        Text(locationManager.isLocationEnabled ? "location_enabled".localized : "location_disabled".localized)
                            .font(.headline)
                    }
                    
                    if let location = locationManager.location {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.blue)
                            Text("current_location".localized + ": \(locationManager.getLocationString())")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal, 40)
                
                // Action Buttons
                VStack(spacing: 15) {
                    // Location Permission Button
                    if locationManager.authorizationStatus == .notDetermined || locationManager.authorizationStatus == .denied {
                        Button(action: {
                            if locationManager.authorizationStatus == .denied {
                                showLocationPermission = true
                            } else {
                                locationManager.requestLocationPermission()
                            }
                        }) {
                            HStack {
                                Image(systemName: "location.circle.fill")
                                    .foregroundColor(.white)
                                Text("allow_location_access".localized)
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(10)
                        }
                    }
                    
                    // Add Activity Button
                    NavigationLink(destination: AddItemView()) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.white)
                            Text("add_activity".localized)
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    
                    // Map Button
                    NavigationLink(destination: MapView()) {
                        HStack {
                            Image(systemName: "map.fill")
                                .foregroundColor(.white)
                            Text("view_map".localized)
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // Footer
            Text("thank_you_using_app".localized)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
        }
        .padding()
        .navigationBarHidden(true)
        .task {
            await loadUserData()
        }
        .alert("location_settings_alert_title".localized, isPresented: $showLocationPermission) {
            Button("cancel".localized) { }
            Button("open_settings".localized) {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        } message: {
            Text("location_settings_alert_message".localized)
        }
    }
    
    @MainActor
    private func loadUserData() async {
        if let user = AuthService.shared.getCurrentUser() {
            userName = user.name
            userEmail = user.email
            userAvatar = user.avatar ?? ""
        } else {
            userName = "User"
            userEmail = "user@example.com"
            userAvatar = ""
        }
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
