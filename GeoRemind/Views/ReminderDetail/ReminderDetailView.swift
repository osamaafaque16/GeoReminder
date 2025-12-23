//
//  ReminderDetailView.swift
//  GeoRemind
//
//  Created by Osama Afaque on 22/12/2025.
//

import SwiftUI

struct ReminderDetailView: View {
    
    var appCoordinator: AppCoordinator
    @State var reminder: Reminder
    @State private var isMarkedCompleted: Bool = true
    
    var body: some View {
        NavigationView {
            
            VStack {
                
                // Card View
                VStack(alignment: .leading, spacing: 15) {
                    Text(reminder.name ?? "")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text("Latitude:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(reminder.latitude)")
                    }
                    
                    HStack {
                        Text("Longitude:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(reminder.longitude)")
                    }
                    
                    HStack {
                        Text("Status:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(reminder.isActive ? "Pending" : "Completed")
                            .foregroundColor(reminder.isActive ? .green : .orange)
                    }
                    
                    HStack {
                        Text("Created date:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(Utility.shared.getServerDate(date: reminder.dateCreated ?? Date()))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(.systemGray6))
                        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 3)
                )
                .padding()
                
                Spacer()
                
                // Mark as Completed Button
                if  isMarkedCompleted {
                    Button(action: {
                        CoreDataManager.shared.updateReminderStatus(id: reminder.id ?? UUID(), isActive: false)
                        Utility.shared.showCustomMessage(message: "Reminder marked as completed successfully.")
                        isMarkedCompleted = false
                    }) {
                        Text(isMarkedCompleted ? "Mark as Completed" : "Already Completed")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(reminder.isActive ? Color.green : Color.gray)
                            .cornerRadius(10)
                    }
                    .padding([.horizontal, .bottom])
                    .disabled(!reminder.isActive)
                }
            }
            .navigationTitle("Reminder Details")
//            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        appCoordinator.popToVC()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding(.top, -4)
                }
                
                if  isMarkedCompleted {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            appCoordinator.showMap(pageType: .reminderDetails,reminder: reminder)
                        }) {
                            HStack(spacing: 4) {
                                Text("View On Map")
                            }
                        }
                        .padding(.top, -4)
                    }
                }
            }
        }
        .onAppear(){
            isMarkedCompleted = reminder.isActive
        }
    }
}

