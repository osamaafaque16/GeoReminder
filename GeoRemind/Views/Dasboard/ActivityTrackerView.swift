//
//  ActivityTrackerView.swift
//  GeoRemind
//
//  Created by Osama Afaque on 20/12/2025.
//

import SwiftUI

struct ActivityTrackerView: View {
    @StateObject private var activityManager = ActivityManager.shared
    @State private var isTracking = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Activity Icon
            
            HStack {
                Image(systemName: activityIcon)
                    .font(.system(size: 80))
                    .foregroundColor(activityColor)
                    .padding()
                
                Spacer()
                
                // Activity Status
                VStack(spacing: 8) {
                    Text("Current Activity")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(activityManager.currentActivity.rawValue)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    
                    // Confidence Badge
                    Text("Confidence: \(activityManager.confidenceString)")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(confidenceBadgeColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            
            
            
            // Start/Stop Tracking Button
            Button(action: toggleTracking) {
                HStack {
                    Image(systemName: isTracking ? "stop.fill" : "play.fill")
                    Text(isTracking ? "Stop Tracking" : "Start Tracking")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isTracking ? Color.red : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(!activityManager.isAuthorized)
            
            // Authorization Status
            if !activityManager.isAuthorized {
                Text("Motion activity tracking is not available or authorized")
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        
    }
    
    func toggleTracking() {
        isTracking.toggle()
        if isTracking {
            activityManager.startTracking()
        } else {
            activityManager.stopTracking()
        }
    }
    
    // Activity icon based on current activity
    private var activityIcon: String {
        switch activityManager.currentActivity {
        case .stationary:
            return "figure.stand"
        case .walking:
            return "figure.walk"
        case .running:
            return "figure.run"
        case .automotive:
            return "car.fill"
        case .cycling:
            return "bicycle"
        case .unknown:
            return "questionmark.circle"
        }
    }
    
    // Activity color
    private var activityColor: Color {
        switch activityManager.currentActivity {
        case .stationary:
            return .gray
        case .walking:
            return .green
        case .running:
            return .orange
        case .automotive:
            return .blue
        case .cycling:
            return .purple
        case .unknown:
            return .secondary
        }
    }
    
    // Confidence badge color
    private var confidenceBadgeColor: Color {
        switch activityManager.confidence {
        case .low:
            return .red
        case .medium:
            return .orange
        case .high:
            return .green
        @unknown default:
            return .gray
        }
    }
}

