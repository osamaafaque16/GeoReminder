//
//  DashboardView.swift
//  GeoRemind
//
//  Created by Osama Afaque on 20/12/2025.
//

import SwiftUI

struct DashboardView: View {
    @State private var stepCount: Int = 0
    @StateObject private var dashboardVM = DashboardViewModel()
    var appCoordinator: AppCoordinator


    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20, pinnedViews: []) {
                    // Step Count Widget
                    StepCountView(stepCount: $stepCount, onFetchSteps: {
                        // Your fetch steps code goes here
                        dashboardVM.fetchStepCount(){ steps in
                            stepCount = steps
                        }
                        
                    })
                    .padding(.horizontal)
                    
                    ActivityTrackerView()
                        .padding(.horizontal)
                    
                        Text("Reminders")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                    
                        
                    RemindersListView(reminders: dashboardVM.reminders, appCoordinator: appCoordinator) { index in
                        dashboardVM.reminders.remove(at: index)
                    }

                }
                .padding(.top)
            }.refreshable {
                dashboardVM.fetchReminders()
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Add your map navigation or action here
                        appCoordinator.showMap(pageType: .dashboard)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "map")
                            Text("Show Map")
                        }
                    }
                }
            }
        }
        .onAppear() {
            dashboardVM.fetchStepCount() { steps in
                self.stepCount = steps
            }
            dashboardVM.fetchReminders()
        }
    }
}




