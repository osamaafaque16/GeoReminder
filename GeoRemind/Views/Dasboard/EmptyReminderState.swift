//
//  EmptyReminderState.swift
//  GeoRemind
//
//  Created by Osama Afaque on 20/12/2025.
//

import SwiftUI

struct EmptyReminderState: View {
    var appCoordinator: AppCoordinator
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
                .padding(.top, 20)
            
            Text("No reminders added")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button(action: {
                // Add your navigation or action to add reminder here
                print("Add reminder tapped")
                appCoordinator.showMap(pageType: .dashboard)
            }) {
                Text("Tap to add reminder")
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
    }
}

