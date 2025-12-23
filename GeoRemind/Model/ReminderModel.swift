//
//  ReminderModel.swift
//  GeoRemind
//
//  Created by Osama Afaque on 20/12/2025.
//

import Foundation

// Reminder Model
struct ReminderModel: Identifiable {
    let id = UUID()
    var title: String
    var time: String
    var isCompleted: Bool
}
