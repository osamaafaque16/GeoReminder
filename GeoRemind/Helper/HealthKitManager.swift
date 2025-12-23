//
//  HealthKitManager.swift
//  GeoRemind
//
//  Created by Osama Afaque on 20/12/2025.
//

import Foundation
import HealthKit

class HealthKitManager {
    
    static let shared = HealthKitManager()
    
    let healthStore = HKHealthStore()
    
    func requestHealthPermission(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        
        healthStore.requestAuthorization(
            toShare: [],
            read: [stepType]
        ) { success, error in
            completion(success)
        }
    }
    
    func fetchTodaySteps(completion: @escaping (Double) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in

            let steps = result?.sumQuantity()?
                .doubleValue(for: HKUnit.count()) ?? 0

            DispatchQueue.main.async {
                completion(steps)
            }
        }

        healthStore.execute(query)
    }

}
