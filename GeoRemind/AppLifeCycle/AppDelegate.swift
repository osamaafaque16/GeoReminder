//
//  AppDelegate.swift
//  GeoRemind
//
//  Created by Osama Afaque on 12/19/25.
//

import UIKit
import CoreData
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        Thread.sleep(forTimeInterval: 2)
        UNUserNotificationCenter.current().delegate = self
        self.requestNotificationPermission()
        LocationManager.shared.requestLocationPermission()
        LocationManager.shared.restoreGeofences(reminders:CoreDataManager.shared.fetchReminders())
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "GeoRemind")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.banner, .sound, .badge, .list])

    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        switch response.actionIdentifier {
        case "MARK_COMPLETE":
            let userInfo = response.notification.request.content.userInfo
            let identifier = userInfo["identifier"] as? String ?? ""
            let reminder = CoreDataManager.shared.fetchReminders()
            if let index = reminder.firstIndex(where: {$0.identifier == identifier}) {
                CoreDataManager.shared.updateReminderStatus(id: reminder[index].id ?? UUID(), isActive: false)
            }
            // Handle mark complete logic here
        case "SNOOZE":
            // Example: Reschedule after 10 min
            NotificationManager.shared.triggerNotificationAfterDelay(seconds: 300)
            
        case UNNotificationDefaultActionIdentifier:
            let userInfo = response.notification.request.content.userInfo
            let identifier = userInfo["identifier"] as? String ?? ""
            
            let geofences = CoreDataManager.shared.fetchReminders()
            
            if let reminder = geofences.first(where: {$0.identifier == identifier}) {
                if let _ = appCoordinator?.navigationController.topViewController as? UIHostingController<ReminderDetailView> {
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.appCoordinator?.showReminderDetail(reminder: reminder)
                }
            }
            
        default:
            break
        }

        completionHandler()
    }
}


extension AppDelegate {
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            print("Permission granted:", granted)
        }
    }
    
}
