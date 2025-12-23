//
//  ReminderDetailViewModel.swift
//  GeoRemind
//
//  Created by Osama Afaque on 24/12/2025.
//

import Foundation
import SwiftUI

// MARK: - ViewModel with Dependency Injection
class ReminderDetailViewModel: ObservableObject {
    @Published var reminder: Reminder
    @Published var isMarkedCompleted: Bool
    
    private let dataService: ReminderDataServiceProtocol
    private let utilityService: UtilityServiceProtocol
    private let coordinator: ReminderCoordinatorProtocol
    
    // Dependency Injection through initializer
    init(
        reminder: Reminder,
        dataService: ReminderDataServiceProtocol = ReminderDataService.shared,
        utilityService: UtilityServiceProtocol = UtilityService.shared,
        coordinator: ReminderCoordinatorProtocol
    ) {
        self.reminder = reminder
        self.isMarkedCompleted = reminder.isActive
        self.dataService = dataService
        self.utilityService = utilityService
        self.coordinator = coordinator
    }
    
    // MARK: - Business Logic Methods
    
    func markAsCompleted() {
        guard reminder.isActive else { return }
        
        dataService.updateReminderStatus(id: reminder.id ?? UUID(), isActive: false)
        utilityService.showCustomMessage(message: "Reminder marked as completed successfully.")
        isMarkedCompleted = false
        reminder.isActive = false
    }
    
    func navigateBack() {
        coordinator.popToVC()
    }
    
    func showOnMap() {
        coordinator.showMap(pageType: .reminderDetails, reminder: reminder)
    }
    
    func getFormattedDate() -> String {
        return utilityService.getServerDate(date: reminder.dateCreated ?? Date())
    }
    
    var statusText: String {
        reminder.isActive ? "Pending" : "Completed"
    }
    
    var statusColor: Color {
        reminder.isActive ? .green : .orange
    }
    
    var buttonBackgroundColor: Color {
        reminder.isActive ? .green : .gray
    }
}
