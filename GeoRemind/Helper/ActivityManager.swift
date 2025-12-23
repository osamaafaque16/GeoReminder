//
//  ActivityManager.swift
//  GeoRemind
//
//  Created by Osama Afaque on 20/12/2025.
//

import CoreMotion
import Foundation

// Activity Type Enum
enum ActivityType: String {
    case stationary = "Stationary"
    case walking = "Walking"
    case running = "Running"
    case automotive = "Driving"
    case cycling = "Cycling"
    case unknown = "Unknown"
}

class ActivityManager: ObservableObject {
    static let shared = ActivityManager()
    
    private let motionActivityManager = CMMotionActivityManager()
    @Published var currentActivity: ActivityType = .unknown
    @Published var confidence: CMMotionActivityConfidence = .low
    @Published var isAuthorized = false
    
    private init() {
        checkAuthorization()
    }
    
    // Check if motion activity tracking is available and authorized
    func checkAuthorization() {
        isAuthorized = CMMotionActivityManager.isActivityAvailable()
    }
    
    // Start tracking activity
    func startTracking() {
        guard CMMotionActivityManager.isActivityAvailable() else {
            print("Motion activity tracking is not available on this device")
            return
        }
        
        motionActivityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let activity = activity else { return }
            self?.processActivity(activity)
        }
        print("Start Tracking User Current Motion")
    }
    
    // Stop tracking activity
    func stopTracking() {
        motionActivityManager.stopActivityUpdates()
        print("Stop Tracking User Current Motion")
    }
    
    // Process activity data
    private func processActivity(_ activity: CMMotionActivity) {
        confidence = activity.confidence
        
        // Determine activity type based on priority
        if activity.stationary {
            currentActivity = .stationary
        } else if activity.walking {
            currentActivity = .walking
        } else if activity.running {
            currentActivity = .running
        } else if activity.automotive {
            currentActivity = .automotive
        } else if activity.cycling {
            currentActivity = .cycling
        } else {
            currentActivity = .unknown
        }
        
        print("Current Activity: \(currentActivity.rawValue), Confidence: \(confidenceString)")
    }
    
    // Get confidence as string
    var confidenceString: String {
        switch confidence {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        @unknown default:
            return "Unknown"
        }
    }
    
    // Query historical activity data
    func queryHistoricalActivity(from startDate: Date, to endDate: Date, completion: @escaping ([CMMotionActivity]) -> Void) {
        guard CMMotionActivityManager.isActivityAvailable() else {
            print("Motion activity tracking is not available")
            completion([])
            return
        }
        
        var activities: [CMMotionActivity] = []
        
        motionActivityManager.queryActivityStarting(from: startDate, to: endDate, to: .main) { (activityArray, error) in
            if let error = error {
                print("Error querying historical activity: \(error.localizedDescription)")
                completion([])
                return
            }
            
            if let activityArray = activityArray {
                activities = activityArray
            }
            
            completion(activities)
        }
    }
}
