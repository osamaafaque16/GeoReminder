//
//  ReminderDetailViewModelTests.swift
//  GeoRemindTests
//
//  Created by Osama Afaque on 24/12/2025.
//

import XCTest

@testable import GeoRemind  

class ReminderDetailViewModelTests: XCTestCase {
    
    // System Under Test
    var sut: ReminderDetailViewModel!
    
    // Mock dependencies
    var mockDataService: MockReminderDataService!
    var mockUtilityService: MockUtilityService!
    var mockCoordinator: MockCoordinator!
    var mockReminder: Reminder!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        print("🧪 Setting up test...")
        
        mockDataService = MockReminderDataService()
        mockUtilityService = MockUtilityService()
        mockCoordinator = MockCoordinator()
        
        print("✅ Mocks created")
        
        mockReminder = Reminder.createMockReminder()
        
        print("✅ Mock reminder created: \(mockReminder.name ?? "nil")")
        
        sut = ReminderDetailViewModel(
            reminder: mockReminder,
            dataService: mockDataService,
            utilityService: mockUtilityService,
            coordinator: mockCoordinator
        )
        
        print("✅ ViewModel initialized")
    }
    
    override func tearDown() {
        sut = nil
        mockDataService = nil
        mockUtilityService = nil
        mockCoordinator = nil
        mockReminder = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testViewModel_WhenInitialized_SetsReminderCorrectly() {
        // Then
        XCTAssertEqual(sut.reminder.name, "Test Reminder")
        XCTAssertEqual(sut.reminder.latitude, 37.7749)
        XCTAssertEqual(sut.reminder.longitude, -122.4194)
        XCTAssertTrue(sut.reminder.isActive)
    }
    
    func testViewModel_WhenInitializedWithActiveReminder_IsMarkedCompletedIsTrue() {
        // Then
        XCTAssertTrue(sut.isMarkedCompleted)
    }
    
    func testViewModel_WhenInitializedWithInactiveReminder_IsMarkedCompletedIsFalse() {
        // Given
        let inactiveReminder = Reminder.createMockReminder(isActive: false)
        
        // When
        let viewModel = ReminderDetailViewModel(
            reminder: inactiveReminder,
            dataService: mockDataService,
            utilityService: mockUtilityService,
            coordinator: mockCoordinator
        )
        
        // Then
        XCTAssertFalse(viewModel.isMarkedCompleted)
    }
    
    // MARK: - Mark As Completed Tests
    
    func testMarkAsCompleted_CallsDataServiceWithCorrectParameters() {
        // When
        sut.markAsCompleted()
        
        // Then
        XCTAssertTrue(mockDataService.updateReminderStatusCalled)
        XCTAssertEqual(mockDataService.updatedReminderID, mockReminder.id)
        XCTAssertEqual(mockDataService.updatedIsActive, false)
    }
    
    func testMarkAsCompleted_CallsUtilityServiceToShowSuccessMessage() {
        // When
        sut.markAsCompleted()
        
        // Then
        XCTAssertTrue(mockUtilityService.showCustomMessageCalled)
        XCTAssertEqual(mockUtilityService.lastMessage, "Reminder marked as completed successfully.")
    }
    
    func testMarkAsCompleted_UpdatesIsMarkedCompletedToFalse() {
        // Given
        XCTAssertTrue(sut.isMarkedCompleted, "Initial state should be true")
        
        // When
        sut.markAsCompleted()
        
        // Then
        XCTAssertFalse(sut.isMarkedCompleted, "Should be false after marking complete")
    }
    
    func testMarkAsCompleted_UpdatesReminderIsActiveToFalse() {
        // Given
        XCTAssertTrue(sut.reminder.isActive, "Initial state should be active")
        
        // When
        sut.markAsCompleted()
        
        // Then
        XCTAssertFalse(sut.reminder.isActive, "Should be inactive after marking complete")
    }
    
    func testMarkAsCompleted_WhenReminderAlreadyInactive_DoesNothing() {
        // Given - Create inactive reminder
        let inactiveReminder = Reminder.createMockReminder(isActive: false)
        sut = ReminderDetailViewModel(
            reminder: inactiveReminder,
            dataService: mockDataService,
            utilityService: mockUtilityService,
            coordinator: mockCoordinator
        )
        
        // When
        sut.markAsCompleted()
        
        // Then - Nothing should be called
        XCTAssertFalse(mockDataService.updateReminderStatusCalled)
        XCTAssertFalse(mockUtilityService.showCustomMessageCalled)
    }
    
    // MARK: - Navigation Tests
    
    func testNavigateBack_CallsCoordinatorPopToVC() {
        // When
        sut.navigateBack()
        
        // Then
        XCTAssertTrue(mockCoordinator.popToVCCalled)
    }
    
    func testShowOnMap_CallsCoordinatorShowMapWithCorrectParameters() {
        // When
        sut.showOnMap()
        
        // Then
        XCTAssertTrue(mockCoordinator.showMapCalled)
        XCTAssertEqual(mockCoordinator.lastPageType, .reminderDetails)
        XCTAssertEqual(mockCoordinator.lastReminder?.id, mockReminder.id)
    }
    
    // MARK: - Status Text Tests
    
    func testStatusText_WhenReminderIsActive_ReturnsPending() {
        // Given
        XCTAssertTrue(sut.reminder.isActive)
        
        // When
        let result = sut.statusText
        
        // Then
        XCTAssertEqual(result, "Pending")
    }
    
    func testStatusText_WhenReminderIsInactive_ReturnsCompleted() {
        // Given
        sut.reminder.isActive = false
        
        // When
        let result = sut.statusText
        
        // Then
        XCTAssertEqual(result, "Completed")
    }
    
    // MARK: - Status Color Tests
    
    func testStatusColor_WhenReminderIsActive_ReturnsGreen() {
        // Given
        XCTAssertTrue(sut.reminder.isActive)
        
        // When
        let result = sut.statusColor
        
        // Then
        XCTAssertEqual(result, .green)
    }
    
    func testStatusColor_WhenReminderIsInactive_ReturnsOrange() {
        // Given
        sut.reminder.isActive = false
        
        // When
        let result = sut.statusColor
        
        // Then
        XCTAssertEqual(result, .orange)
    }
    
    // MARK: - Button Color Tests
    
    func testButtonBackgroundColor_WhenReminderIsActive_ReturnsGreen() {
        // Given
        XCTAssertTrue(sut.reminder.isActive)
        
        // When
        let result = sut.buttonBackgroundColor
        
        // Then
        XCTAssertEqual(result, .green)
    }
    
    func testButtonBackgroundColor_WhenReminderIsInactive_ReturnsGray() {
        // Given
        sut.reminder.isActive = false
        
        // When
        let result = sut.buttonBackgroundColor
        
        // Then
        XCTAssertEqual(result, .gray)
    }
    
    // MARK: - Date Formatting Tests
    
    func testGetFormattedDate_CallsUtilityServiceAndReturnsFormattedString() {
        // Given
        mockUtilityService.mockDateString = "2024-12-24 10:30 AM"
        
        // When
        let result = sut.getFormattedDate()
        
        // Then
        XCTAssertEqual(result, "2024-12-24 10:30 AM")
    }
    
    // MARK: - Integration Tests
    
    func testMarkAsCompletedFlow_UpdatesAllComponents() {
        // Given - Initial state
        XCTAssertTrue(sut.reminder.isActive)
        XCTAssertTrue(sut.isMarkedCompleted)
        
        // When - User marks as completed
        sut.markAsCompleted()
        
        // Then - All components updated
        XCTAssertFalse(sut.reminder.isActive, "Reminder should be inactive")
        XCTAssertFalse(sut.isMarkedCompleted, "Flag should be false")
        XCTAssertTrue(mockDataService.updateReminderStatusCalled, "Data service should be called")
        XCTAssertTrue(mockUtilityService.showCustomMessageCalled, "Message should be shown")
        XCTAssertEqual(mockDataService.updatedIsActive, false, "Should update to inactive")
    }
    
    // MARK: - Edge Case Tests
    
    func testViewModel_WithNilReminderId_HandlesGracefully() {
        // Given
        mockReminder.id = nil
        
        // When
        sut.markAsCompleted()
        
        // Then - Should still work (uses UUID() as fallback)
        XCTAssertTrue(mockDataService.updateReminderStatusCalled)
    }
    
    func testViewModel_WithNilReminderName_HandlesGracefully() {
        // Given
        mockReminder.name = nil
        
        // When
        let name = sut.reminder.name
        
        // Then
        XCTAssertNil(name)
    }
    
    func testViewModel_WithNilDateCreated_HandlesGracefully() {
        // Given
        mockReminder.dateCreated = nil
        
        // When
        let formattedDate = sut.getFormattedDate()
        
        // Then - Should use Date() as fallback
        XCTAssertNotNil(formattedDate)
    }
}
