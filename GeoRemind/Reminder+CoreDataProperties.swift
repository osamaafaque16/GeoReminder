//
//  Reminder+CoreDataProperties.swift
//  GeoRemind
//
//  Created by Osama Afaque on 12/19/25.
//
//

import Foundation
import CoreData


extension Reminder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        return NSFetchRequest<Reminder>(entityName: "Reminder")
    }

    @NSManaged public var name: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var dateCreated: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isActive: Bool
    @NSManaged public var identifier: String
    @NSManaged public var radius: Double
}

extension Reminder : Identifiable {

}
