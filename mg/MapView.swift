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
    @StateObject private var locationManager = LocationManager()
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Image(systemName: "location.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text("Current Location")
                        .font(.headline)
                    if let location = locationManager.location {
                        Text("Lat: \(location.coordinate.latitude, specifier: "%.4f")")
                            .font(.caption)
                        Text("Lng: \(location.coordinate.longitude, specifier: "%.4f")")
                            .font(.caption)
                    } else {
                        Text("Getting location...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    locationManager.requestLocation()
                }) {
                    Image(systemName: "location.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
            // Map with modern iOS 17+ API
            Map(position: $position) {
                if let location = locationManager.location {
                    Marker("You are here", coordinate: location.coordinate)
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
                }
            }
            .onAppear {
                locationManager.requestLocation()
            }
            
            // Status
            HStack {
                if locationManager.authorizationStatus == .denied {
                    Text("Location access denied. Please enable in Settings.")
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
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocation() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
}

#Preview {
    NavigationView {
        MapView()
    }
}
