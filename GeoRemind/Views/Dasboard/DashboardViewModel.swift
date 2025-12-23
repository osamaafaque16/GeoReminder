//
//  DashboardViewModel.swift
//  GeoRemind
//
//  Created by Osama Afaque on 20/12/2025.
//

import Foundation

class DashboardViewModel: ObservableObject {
    
    @Published var reminders: [Reminder] = []
    
    func fetchReminders() {
        reminders = CoreDataManager.shared.fetchReminders()
    }
    
    func fetchStepCount(completion: @escaping (Int) -> Void) {
        
        HealthKitManager.shared.requestHealthPermission { granted in
            if granted {
                HealthKitManager.shared.fetchTodaySteps { steps in
                    print("Today's steps: \(Int(steps))")
                    completion(Int(steps))
                }
            }else {
                print("Not Granted")
            }
        }
    }
}
