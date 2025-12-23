//
//  RichNotificationManager.swift
//  GeoRemind
//
//  Created by Osama Afaque on 21/12/2025.
//

import Foundation
import UIKit
import UserNotifications

class NotificationManager:NSObject {

    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        requestNotificationPermission()
        setupNotificationActions()
    }
    
    // 1. Request permission
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notifications: \(error)")
            }
        }
    }
    
    // 2. Define actions & category
    private func setupNotificationActions() {
        let markCompleteAction = UNNotificationAction(identifier: "MARK_COMPLETE",
                                                      title: "Mark Complete",
                                                      options: [.foreground])
        let snoozeAction = UNNotificationAction(identifier: "SNOOZE",
                                                title: "Snooze",
                                                options: [])
        
        let category = UNNotificationCategory(identifier: "REMINDER_CATEGORY",
                                              actions: [markCompleteAction, snoozeAction],
                                              intentIdentifiers: [],
                                              options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    // 3. Schedule notification
    func triggerNotification(title: String, body: String,reminder: Reminder?) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "REMINDER_CATEGORY" // Link category for actions
        
        
        let userInfo: [String: Any] = [
            "identifier":reminder?.identifier ?? ""
        ]
        content.userInfo = userInfo
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func triggerNotificationAfterDelay(seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "This is your snoozed reminder."
        content.sound = .default
        content.categoryIdentifier = "REMINDER_CATEGORY"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

