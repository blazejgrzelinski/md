//
//  AddItemView.swift
//  mg
//
//  Created by Blazej Grzelinski on 09/10/2025.
//

import SwiftUI

struct Activity: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
}

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedActivity: Activity?
    @State private var itemName = ""
    @State private var itemDescription = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private let activities = [
        Activity(name: "running".localized, icon: "figure.run", color: .green),
        Activity(name: "cycling".localized, icon: "bicycle", color: .blue),
        Activity(name: "hiking".localized, icon: "figure.hiking", color: .brown),
        Activity(name: "swimming".localized, icon: "figure.pool.swim", color: .cyan),
        Activity(name: "gym".localized, icon: "dumbbell", color: .orange),
        Activity(name: "yoga".localized, icon: "figure.yoga", color: .purple),
        Activity(name: "tennis".localized, icon: "tennis.racket", color: .yellow),
        Activity(name: "basketball".localized, icon: "basketball", color: .red),
        Activity(name: "football".localized, icon: "soccerball", color: .mint),
        Activity(name: "volleyball".localized, icon: "volleyball", color: .pink),
        Activity(name: "boxing".localized, icon: "figure.boxing", color: .indigo),
        Activity(name: "dancing".localized, icon: "figure.dance", color: .teal)
    ]
    
    private var filteredActivities: [Activity] {
        if searchText.isEmpty {
            return activities
        } else {
            return activities.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Text("add_new_activity".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("choose_activity_add_details".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Item Details Section
                VStack(spacing: 15) {
                    TextField("activity_name_optional".localized, text: $itemName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("description_optional".localized, text: $itemDescription, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                .padding(.horizontal)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("search_activities".localized, text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Activities List
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredActivities) { activity in
                            ActivityRow(
                                activity: activity,
                                isSelected: selectedActivity?.id == activity.id
                            ) {
                                selectedActivity = activity
                                if itemName.isEmpty {
                                    itemName = activity.name
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Add Button
                Button(action: addItem) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("add_activity_button".localized)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedActivity != nil ? Color.blue : Color.gray)
                    .cornerRadius(10)
                }
                .disabled(selectedActivity == nil)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("add".localized) {
                        addItem()
                    }
                    .disabled(selectedActivity == nil)
                }
            }
            .alert("activity_added".localized, isPresented: $showAlert) {
                Button("ok".localized) {
                    dismiss()
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func addItem() {
        guard let activity = selectedActivity else { return }
        
        let finalName = itemName.isEmpty ? activity.name : itemName
        
        alertMessage = "added_activity".localized(with: finalName)
        showAlert = true
        
        // Here you would typically save to your data store
        print("✅ Added activity: \(finalName)")
        print("📝 Description: \(itemDescription)")
        print("🏃 Activity type: \(activity.name)")
    }
}

struct ActivityRow: View {
    let activity: Activity
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                Image(systemName: activity.icon)
                    .font(.title2)
                    .foregroundColor(activity.color)
                    .frame(width: 30)
                
                Text(activity.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AddItemView()
}
