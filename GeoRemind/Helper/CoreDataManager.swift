//
//  CoreDataManager.swift
//  GeoRemind
//
//  Created by Osama Afaque on 12/19/25.
//

import Foundation
import CoreData
import SwiftUI

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "Reminder")
        container.loadPersistentStores { (desc, error) in
            if let error = error {
                fatalError("Failed to load Core Data: \(error.localizedDescription)")
            }
        }
    }
    
    // Save context
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    // Add reminder
    func addReminder(name: String, latitude: Double, longitude: Double,identifier: String,radius: Double, isActive: Bool) {
        let context = container.viewContext
        let reminder = Reminder(context: context)
        reminder.id = UUID()
        reminder.name = name
        reminder.latitude = latitude
        reminder.longitude = longitude
        reminder.dateCreated = Date()
        reminder.identifier = identifier
        reminder.radius = radius
        reminder.isActive = isActive
        save()
    }
    
    // Fetch all reminders
    func fetchReminders() -> [Reminder] {
        let context = container.viewContext
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch reminders: \(error)")
            return []
        }
    }
    
    // Delete reminder by ID
//    func deleteReminder(withId id: UUID,completion: @escaping () -> Void) {
//        let context = container.viewContext
//        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
//        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
//        
//        do {
//            let results = try context.fetch(request)
//            if let reminderToDelete = results.first {
//                context.delete(reminderToDelete)
//                save()
//                completion()
//            }
//        } catch {
//            print("Failed to delete reminder: \(error)")
//        }
//    }
    
    func deleteReminder(withIdentifier identifier: String, completion: @escaping () -> Void) {
        let context = container.viewContext
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        request.predicate = NSPredicate(format: "identifier == %@", identifier)
        request.fetchLimit = 1
        
        do {
            if let reminderToDelete = try context.fetch(request).first {
                context.delete(reminderToDelete)
                save()
                completion()
            } else {
                print("No reminder found with identifier: \(identifier)")
            }
        } catch {
            print("Failed to delete reminder by identifier: \(error)")
        }
    }
    
    // Update reminder by ID
    func updateReminderStatus(id: UUID,isActive: Bool,completion: (() -> Void)? = nil) {
        let context = container.viewContext
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        do {
            if let reminder = try context.fetch(request).first {
                reminder.isActive = isActive
                save()
                completion?()
            }
        } catch {
            print("Failed to update isActive: \(error)")
        }
    }
}
