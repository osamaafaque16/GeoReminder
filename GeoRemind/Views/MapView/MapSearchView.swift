//
//  MapSearchView.swift
//  GeoRemind
//
//  Created by Osama Afaque on 12/19/25.
//


import SwiftUI
import MapKit
import Combine

enum MapSearchViewType {
    
    case dashboard
    case reminderDetails
}

struct MapSearchView: View {
    
    var appCoordinator: AppCoordinator
    var pageType: MapSearchViewType = .dashboard

    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var searchVM = MapSearchViewModel()
    
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    @State private var showSuggestions: Bool = false
    
    // Selected location for marker
    @State private var selectedLocation: MKMapItem?
    
    // Track which marker popup is visible
    @State private var showPopup: Bool = false
    
    @State private var savedReminders: [Reminder] = []
    
    @State var selectedReminder: Reminder?
    
    

    
    var body: some View {
        ZStack {
            
            // MARK: - Map
            Map(position: $cameraPosition) {
                // User location
                if let location = locationManager.location {
                    Annotation("My Location", coordinate: location.coordinate) {
                        ZStack {
                            Circle().fill(Color.blue).frame(width: 16, height: 16)
                            Circle().stroke(Color.white, lineWidth: 3).frame(width: 16, height: 16)
                            Circle().fill(Color.blue.opacity(0.2)).frame(width: 44, height: 44)
                        }
                    }
                }
                
                
                if pageType == .dashboard {
                    // Multiples Geofence circles
                    ForEach(savedReminders, id: \.id) { reminder in
                        if reminder.isActive {
                            let center = CLLocationCoordinate2D(
                                latitude: reminder.latitude,
                                longitude: reminder.longitude
                            )
                            
                            let isActive = locationManager.activeGeofenceID == reminder.identifier
                            
                            MapCircle(center: center, radius: reminder.radius)
                                .foregroundStyle(
                                    isActive
                                    ? Color.green.opacity(0.35)
                                    : Color.blue.opacity(0.25)
                                )
                                .stroke(
                                    isActive ? Color.green : Color.blue,
                                    lineWidth: isActive ? 3 : 1.5
                                )
                        }
                    }
                }else {
                    // Selected Geofence circle
                    if let reminder = selectedReminder {
                        
                        if reminder.isActive {
                            let center = CLLocationCoordinate2D(
                                latitude: reminder.latitude,
                                longitude: reminder.longitude
                            )
                            
                            let isActive = locationManager.activeGeofenceID == reminder.identifier
                            
                            MapCircle(center: center, radius: reminder.radius)
                                .foregroundStyle(
                                    isActive
                                    ? Color.green.opacity(0.35)
                                    : Color.blue.opacity(0.25)
                                )
                                .stroke(
                                    isActive ? Color.green : Color.blue,
                                    lineWidth: isActive ? 3 : 1.5
                                )
                        }
                    }
                    
                }
                
                // Selected location marker
                if let selected = selectedLocation,
                   let coordinate = selected.placemark.location?.coordinate {
                    Annotation(selectedLocation?.name ?? "", coordinate: coordinate) {
                        Button(action: {
                            // Show popup when marker tapped
                            showPopup = true
                        }) {
                            Image(systemName: "mappin.circle.fill")
                                .resizable()
                                .foregroundColor(.red)
                                .frame(width: 30, height: 30)
                        }
                    }
                }
                if pageType == .dashboard {
                    // SAVED REMINDERS MARKERS
                    ForEach(savedReminders, id: \.id) { reminder in
                        if reminder.isActive {
                            let coordinate = CLLocationCoordinate2D(
                                latitude: reminder.latitude,
                                longitude: reminder.longitude
                            )
                            Group {
                                Annotation(reminder.name ?? "Reminder", coordinate: coordinate) {
                                    Image("marker_icon")
                                        .resizable()
                                        .frame(width: 32, height: 32	)
                                }
                            }
                        }
                    }
                }else {
                    // SELECTED REMINDERS MARKERS
                    if let reminder = selectedReminder {
                        if reminder.isActive {
                            let coordinate = CLLocationCoordinate2D(
                                latitude: reminder.latitude,
                                longitude: reminder.longitude
                            )
                            Group {
                                Annotation(reminder.name ?? "Reminder", coordinate: coordinate) {
                                    Image("marker_icon")
                                        .resizable()
                                        .frame(width: 32, height: 32    )
                                }
                            }
                        }
                    }
                }
            }
            .mapControls {
//                MapUserLocationButton()
//                MapCompass()
            }
            .mapStyle(.standard(elevation: .realistic))
            .onAppear {
                locationManager.requestLocationPermission()
                locationManager.startUpdatingLocation()
                savedReminders =  CoreDataManager.shared.fetchReminders()
            }
            .onTapGesture {
                hideKeyboard()
                showSuggestions = false
                showPopup = false
            }
            
            VStack(alignment: .leading,spacing: 0) {
                
                Button(action: {
                    appCoordinator.popToVC() // or your custom back action
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                .padding(.leading, 16)
                .padding(.top, -12)
                
                
                // MARK: - Search Bar
                if pageType == .dashboard {
                    HStack {
                        TextField("Search for address", text: $searchVM.query, onEditingChanged: { editing in
                            showSuggestions = editing
                        })
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        
                        if !searchVM.query.isEmpty {
                            Button(action: {
                                searchVM.query = ""
                                searchVM.results = []
                                showSuggestions = false
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .frame(width: 32,height: 32)
                            }
                        }
                    }
                    .padding()
                }
                
                // MARK: - Suggestions List
                if showSuggestions && !searchVM.results.isEmpty {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(searchVM.results, id: \.self) { item in
                                Button(action: {
                                    selectSearchResult(item)
                                }) {
                                    HStack {
                                        Image(systemName: "mappin.and.ellipse")
                                            .foregroundColor(.blue)
                                        Text(item.name ?? "")
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(8)
                                    .shadow(radius: 1)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 250)
                    .transition(.opacity)
                }
                
                Spacer()
                
                // MARK: - Location Status & Center Button
                VStack(spacing: 12) {
                    if let error = locationManager.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                    } else if locationManager.authorizationStatus == .notDetermined {
                        HStack {
                            Image(systemName: "location.circle")
                                .foregroundColor(.blue)
                            Text("Requesting location permission...")
                                .font(.caption)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                    } else if locationManager.location != nil {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.green)
                            Text("Location found")
                                .font(.caption)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                    }
                    
                    if locationManager.authorizationStatus == .authorizedWhenInUse ||
                        locationManager.authorizationStatus == .authorizedAlways {
                        HStack {
                            Spacer()
                            Button(action: centerOnUserLocation) {
                                HStack {
                                    Image(systemName: "location.fill")
                                    Text("Center on My Location")
                                }
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .cornerRadius(25)
                            }
                            Spacer()
                        }

                    }
                }
                .padding(.bottom, 20)
            }
            
            // MARK: - Center Popup
            if showPopup, let location = selectedLocation {
                VStack {
                    Spacer(minLength: 0)
                    VStack(spacing: 12) {
                        Text(location.name ?? "Selected Location")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            print("Add reminder tapped at \(location.name ?? "")")
                            showPopup = false
                            if let _ = CoreDataManager.shared.fetchReminders().firstIndex(where: {$0.identifier == location.identifier?.rawValue ?? ""}) {
                                Utility.shared.showCustomMessage(message: "You already have a reminder set for this location!",theme: .error)
                            }else {
                                addReminder()
                            }

                        }) {
                            Text("Add reminder to this location")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                    .padding(.horizontal, 40)
                    Spacer(minLength: 0)
                }
                .transition(.scale)
                .animation(.easeInOut, value: showPopup)
            }
        }
    }
    
    // MARK: - Functions
    private func selectSearchResult(_ item: MKMapItem) {
        selectedLocation = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showPopup = true
        }
        
        if let coordinate = item.placemark.location?.coordinate {
            withAnimation {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )
            }
        }
        searchVM.results = []
        searchVM.query = item.name ?? ""
        showSuggestions = false
        hideKeyboard()
    }
    
    private func centerOnUserLocation() {
        guard let location = locationManager.location else {
            locationManager.startUpdatingLocation()
            return
        }
        withAnimation(.easeInOut(duration: 0.5)) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )
        }
        print("LATITUDE = \(location.coordinate.latitude)")
        print("LONGIUDE = \(location.coordinate.longitude)")
    }
    
    private func addReminder() {
        guard let location = selectedLocation,
              let coordinate = location.placemark.location?.coordinate else { return }

        CoreDataManager.shared.addReminder(
            name: location.name ?? "Unknown",
            latitude: coordinate.latitude,
            longitude:  coordinate.longitude,
            identifier: location.identifier?.rawValue ?? "",
            radius: 100,
            isActive: true
        )
        
        print("\(location.name ?? "") and identifeir = \(location.identifier?.rawValue ?? "") ")
        
        
        locationManager.startMonitoringGeofence(identifier: location.identifier?.rawValue ?? "",
                                                latitude:  coordinate.latitude,
                                                longitude:  coordinate.longitude,
                                                radius: 100,
                                                triggerOnEntry: true,
                                                triggerOnExit: true)
        Utility.shared.showCustomMessage(message: "GeoFence reminder added successfully")
        appCoordinator.popToVC()
        
    }
    

        
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}





//#Preview {
//    MapSearchView()
//}
