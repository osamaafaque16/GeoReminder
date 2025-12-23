//
//  ReminderDetailView.swift
//  GeoRemind
//
//  Created by Osama Afaque on 22/12/2025.
//

import SwiftUI
import CoreData

// MARK: - Protocol for Dependency Injection

/// Protocol for Core Data operations
protocol ReminderDataServiceProtocol {
    func updateReminderStatus(id: UUID, isActive: Bool)
}

/// Protocol for Utility operations
protocol UtilityServiceProtocol {
    func showCustomMessage(message: String)
    func getServerDate(date: Date) -> String
}

/// Protocol for Coordinator/Navigation
protocol ReminderCoordinatorProtocol {
    func popToVC()
    func showMap(pageType: MapSearchViewType, reminder: Reminder)
}

// MARK: - Production Implementations

class ReminderDataService: ReminderDataServiceProtocol {
    static let shared = ReminderDataService()
    
    func updateReminderStatus(id: UUID, isActive: Bool) {
        // Your actual Core Data implementation
        CoreDataManager.shared.updateReminderStatus(id: id, isActive: isActive)
    }
}

class UtilityService: UtilityServiceProtocol {
    static let shared = UtilityService()
    
    func showCustomMessage(message: String) {
        // Your actual utility implementation
        Utility.shared.showCustomMessage(message: message)
    }
    
    func getServerDate(date: Date) -> String {
        // Your actual date formatting implementation
        return Utility.shared.getServerDate(date: date)
    }
}



// MARK: - Refactored View with ViewModel

struct ReminderDetailView: View {
    @StateObject var viewModel: ReminderDetailViewModel

    
    init(reminder: Reminder, appCoordinator: AppCoordinator) {
        _viewModel = StateObject(wrappedValue: ReminderDetailViewModel(
            reminder: reminder,
            coordinator: appCoordinator
        ))
    }
    
    // Custom initializer for testing with injected dependencies
    init(viewModel: ReminderDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Card View
                reminderCardView
                
                Spacer()
                
                // Mark as Completed Button
                if viewModel.isMarkedCompleted {
                    completedButton
                }
            }
            .navigationTitle("Reminder Details")
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
                
                if viewModel.isMarkedCompleted {
                    ToolbarItem(placement: .topBarTrailing) {
                        mapButton
                    }
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var reminderCardView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(viewModel.reminder.name ?? "")
                .font(.title2)
                .fontWeight(.bold)
            
            DetailRow(label: "Latitude:", value: "\(viewModel.reminder.latitude)")
            DetailRow(label: "Longitude:", value: "\(viewModel.reminder.longitude)")
            
            HStack {
                Text("Status:")
                    .fontWeight(.semibold)
                Spacer()
                Text(viewModel.statusText)
                    .foregroundColor(viewModel.statusColor)
            }
            
            DetailRow(label: "Created date:", value: viewModel.getFormattedDate())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemGray6))
                .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 3)
        )
        .padding()
    }
    
    private var completedButton: some View {
        Button(action: {
            viewModel.markAsCompleted()
        }) {
            Text(viewModel.isMarkedCompleted ? "Mark as Completed" : "Already Completed")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.buttonBackgroundColor)
                .cornerRadius(10)
        }
        .padding([.horizontal, .bottom])
        .disabled(!viewModel.reminder.isActive)
    }
    
    private var backButton: some View {
        Button(action: {
            viewModel.navigateBack()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.6))
                .clipShape(Circle())
        }
        .padding(.top, -4)
    }
    
    private var mapButton: some View {
        Button(action: {
            viewModel.showOnMap()
        }) {
            Text("View On Map")
        }
        .padding(.top, -4)
    }
}

// MARK: - Helper View Component

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.semibold)
            Spacer()
            Text(value)
        }
    }
}

// MARK: - Mock Services for Testing

class MockReminderDataService: ReminderDataServiceProtocol {
    var updateReminderStatusCalled = false
    var updatedReminderID: UUID?
    var updatedIsActive: Bool?
    
    func updateReminderStatus(id: UUID, isActive: Bool) {
        updateReminderStatusCalled = true
        updatedReminderID = id
        updatedIsActive = isActive
    }
}

class MockUtilityService: UtilityServiceProtocol {
    var showCustomMessageCalled = false
    var lastMessage: String?
    var mockDateString = "2024-12-24 10:30 AM"
    
    func showCustomMessage(message: String) {
        showCustomMessageCalled = true
        lastMessage = message
    }
    
    func getServerDate(date: Date) -> String {
        return mockDateString
    }
}

class MockCoordinator: ReminderCoordinatorProtocol {
    var popToVCCalled = false
    var showMapCalled = false
    var lastPageType: MapSearchViewType?
    var lastReminder: Reminder?
    
    func popToVC() {
        popToVCCalled = true
    }
    
    func showMap(pageType: MapSearchViewType, reminder: Reminder) {
        showMapCalled = true
        lastPageType = pageType
        lastReminder = reminder
    }
}

// MARK: - Mock Reminder Helper

extension Reminder {
    static func createMockReminder(
        id: UUID = UUID(),
        name: String = "Test Reminder",
        latitude: Double = 37.7749,
        longitude: Double = -122.4194,
        isActive: Bool = true,
        dateCreated: Date = Date()
    ) -> Reminder {
        // For testing, you might need to create this differently
        // based on how your Core Data model is set up
        let reminder = Reminder()
        reminder.id = id
        reminder.name = name
        reminder.latitude = latitude
        reminder.longitude = longitude
        reminder.isActive = isActive
        reminder.dateCreated = dateCreated
        return reminder
    }
}



//struct ReminderDetailView: View {
//
//    var appCoordinator: AppCoordinator
//    @State var reminder: Reminder
//    @State private var isMarkedCompleted: Bool = true
//
//    var body: some View {
//        NavigationView {
//
//            VStack {
//
//                // Card View
//                VStack(alignment: .leading, spacing: 15) {
//                    Text(reminder.name ?? "")
//                        .font(.title2)
//                        .fontWeight(.bold)
//
//                    HStack {
//                        Text("Latitude:")
//                            .fontWeight(.semibold)
//                        Spacer()
//                        Text("\(reminder.latitude)")
//                    }
//
//                    HStack {
//                        Text("Longitude:")
//                            .fontWeight(.semibold)
//                        Spacer()
//                        Text("\(reminder.longitude)")
//                    }
//
//                    HStack {
//                        Text("Status:")
//                            .fontWeight(.semibold)
//                        Spacer()
//                        Text(reminder.isActive ? "Pending" : "Completed")
//                            .foregroundColor(reminder.isActive ? .green : .orange)
//                    }
//
//                    HStack {
//                        Text("Created date:")
//                            .fontWeight(.semibold)
//                        Spacer()
//                        Text(Utility.shared.getServerDate(date: reminder.dateCreated ?? Date()))
//                    }
//                }
//                .padding()
//                .background(
//                    RoundedRectangle(cornerRadius: 15)
//                        .fill(Color(.systemGray6))
//                        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 3)
//                )
//                .padding()
//
//                Spacer()
//
//                // Mark as Completed Button
//                if  isMarkedCompleted {
//                    Button(action: {
//                        CoreDataManager.shared.updateReminderStatus(id: reminder.id ?? UUID(), isActive: false)
//                        Utility.shared.showCustomMessage(message: "Reminder marked as completed successfully.")
//                        isMarkedCompleted = false
//                    }) {
//                        Text(isMarkedCompleted ? "Mark as Completed" : "Already Completed")
//                            .fontWeight(.bold)
//                            .foregroundColor(.white)
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(reminder.isActive ? Color.green : Color.gray)
//                            .cornerRadius(10)
//                    }
//                    .padding([.horizontal, .bottom])
//                    .disabled(!reminder.isActive)
//                }
//            }
//            .navigationTitle("Reminder Details")
////            .navigationBarTitleDisplayMode(.inline)
//            .background(Color(.systemGroupedBackground))
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    Button(action: {
//                        appCoordinator.popToVC()
//                    }) {
//                        Image(systemName: "chevron.left")
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.black.opacity(0.6))
//                            .clipShape(Circle())
//                    }
//                    .padding(.top, -4)
//                }
//
//                if  isMarkedCompleted {
//                    ToolbarItem(placement: .topBarTrailing) {
//                        Button(action: {
//                            appCoordinator.showMap(pageType: .reminderDetails,reminder: reminder)
//                        }) {
//                            HStack(spacing: 4) {
//                                Text("View On Map")
//                            }
//                        }
//                        .padding(.top, -4)
//                    }
//                }
//            }
//        }
//        .onAppear(){
//            isMarkedCompleted = reminder.isActive
//        }
//    }
//}
