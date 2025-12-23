//
//  LocationManager.swift
//  GeoRemind
//
//  Created by Osama Afaque on 12/19/25.
//


import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject {
    
    static let shared = LocationManager()   // ✅ SINGLE INSTANCE
    
    @Published var activeGeofenceID: String?
    
    private  let activityManager = ActivityManager.shared

    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    
   private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 15
//        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .automotiveNavigation


        authorizationStatus = locationManager.authorizationStatus

    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestLocationPermission()
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - GEOFENCING
extension LocationManager {
    
    func startMonitoringGeofence(identifier: String,latitude: Double,longitude: Double,radius: Double,triggerOnEntry: Bool,
                                 triggerOnExit: Bool) {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else { return }

        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        let region = CLCircularRegion(
            center: center,
            radius: max(radius, 100), // minimum safe radius
            identifier: identifier
        )

        region.notifyOnEntry = triggerOnEntry
        region.notifyOnExit = triggerOnExit

        locationManager.startMonitoring(for: region)
    }

    func stopMonitoringGeofence(identifier: String) {
        for region in locationManager.monitoredRegions {
            if region.identifier == identifier {
                locationManager.stopMonitoring(for: region)
            }
        }
    }

    // Restore geofences on app launch
    func restoreGeofences(reminders: [Reminder]) {
        for reminder in reminders {
            startMonitoringGeofence(
                identifier: reminder.identifier,
                latitude: reminder.latitude,
                longitude: reminder.longitude,
                radius: reminder.radius,
                triggerOnEntry: true,
                triggerOnExit: true
            )
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager : CLLocationManagerDelegate{
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = error.localizedDescription
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted:
            errorMessage = "Location access denied. Please enable location services in Settings."
        case .notDetermined:
            requestLocationPermission()
        @unknown default:
            break
        }
    }
    
    // MARK: - GEOFENCE EVENTS

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("ENTER IN THE REGION")
        activityManager.startTracking()
        DispatchQueue.main.async {
            self.activeGeofenceID = region.identifier
        }
        
        let currentMotionState = fetchCurrentActivityState()
        let reminder = fetchReeminder(identifier: region.identifier)
        
        if reminder != nil && reminder?.isActive == true {
            
            NotificationManager.shared.triggerNotification(title: "Reminder",
                                                           body: "You arrived at \(reminder?.name ?? "") while \(currentMotionState)",
                                                           reminder: reminder)
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        print("EXIT THE REGION")
        activityManager.stopTracking()
        
        DispatchQueue.main.async {
            if self.activeGeofenceID == region.identifier {
                self.activeGeofenceID = nil
            }
        }
        
        let reminder = fetchReeminder(identifier: region.identifier)
        let currentMotionState = fetchCurrentActivityState()
          
        if reminder != nil && reminder?.isActive == true {
            
            NotificationManager.shared.triggerNotification(title: "Reminder",
                                                           body: "You exited at \(reminder?.name ?? "") while \(currentMotionState)", reminder: reminder)
        }
    }
    
    private func fetchReeminder(identifier: String) -> Reminder? {
        
        let geofences = CoreDataManager.shared.fetchReminders()
        
        if let geofence = geofences.first(where: {$0.identifier == identifier}) {
            return geofence
        }
        return nil
        
    }
    
    private func fetchCurrentActivityState() -> String {
        
        var currentState = ""
        
        switch activityManager.currentActivity {
            
        case .walking:
            currentState = "walking"
        case .running:
            currentState = "running"
        case .cycling:
            currentState = "cycling"
        case .stationary:
            currentState = "stationary"
        case .automotive:
            currentState = "driving"
        case .unknown:
            currentState = "unknown"
        }
        return currentState
    }
}
