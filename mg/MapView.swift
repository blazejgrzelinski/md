//
//  MapView.swift
//  mg
//
//  Created by Blazej Grzelinski on 07/10/2025.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @StateObject private var locationManager = LocationManager.shared
    @State private var position: MapCameraPosition = .automatic
    @State private var showLocationPermission = false
    @State private var currentAddress: String?
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Image(systemName: locationManager.isLocationEnabled ? "location.circle.fill" : "location.slash.circle.fill")
                    .foregroundColor(locationManager.isLocationEnabled ? .blue : .red)
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text("current_location".localized)
                        .font(.headline)
                    if let location = locationManager.location {
                        Text("Lat: \(location.coordinate.latitude, specifier: "%.4f")")
                            .font(.caption)
                        Text("Lng: \(location.coordinate.longitude, specifier: "%.4f")")
                            .font(.caption)
                        if let address = currentAddress {
                            Text(address)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    } else {
                        Text("location_unknown".localized)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    // Center on location button
                    Button(action: {
                        centerOnUserLocation()
                    }) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(!locationManager.isLocationEnabled)
                    
                    // Request permission button
                    if locationManager.authorizationStatus == .notDetermined || locationManager.authorizationStatus == .denied {
                        Button(action: {
                            if locationManager.authorizationStatus == .denied {
                                showLocationPermission = true
                            } else {
                                locationManager.requestLocationPermission()
                            }
                        }) {
                            Image(systemName: "location.circle")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.orange)
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
            // Map with modern iOS 17+ API
            Map(position: $position) {
                if let location = locationManager.location {
                    Marker("current_location".localized, coordinate: location.coordinate)
                        .tint(.blue)
                }
                UserAnnotation()
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .onChange(of: locationManager.location) { oldValue, newValue in
                if let location = newValue {
                    position = .camera(
                        MapCamera(
                            centerCoordinate: location.coordinate,
                            distance: 1000,
                            heading: 0,
                            pitch: 0
                        )
                    )
                    
                    // Get address for the new location
                    locationManager.getAddressFromLocation { address in
                        currentAddress = address
                    }
                }
            }
            .onAppear {
                if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
                    locationManager.startLocationUpdates()
                } else {
                    locationManager.requestLocationPermission()
                }
            }
            
            // Status
            HStack {
                if locationManager.authorizationStatus == .denied {
                    Text("location_settings_alert_message".localized)
                        .foregroundColor(.red)
                        .font(.caption)
                } else if locationManager.authorizationStatus == .notDetermined {
                    Text("Requesting location permission...")
                        .foregroundColor(.orange)
                        .font(.caption)
                } else if locationManager.location != nil {
                    Text("Location found!")
                        .foregroundColor(.green)
                        .font(.caption)
                } else {
                    Text("Searching for location...")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("map".localized)
        .navigationBarTitleDisplayMode(.inline)
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
    
    // MARK: - Helper Functions
    private func centerOnUserLocation() {
        guard let location = locationManager.location else { return }
        
        withAnimation(.easeInOut(duration: 1.0)) {
            position = .camera(
                MapCamera(
                    centerCoordinate: location.coordinate,
                    distance: 1000,
                    heading: 0,
                    pitch: 0
                )
            )
        }
    }
}

#Preview {
    NavigationView {
        MapView()
    }
}
