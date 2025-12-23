//
//  ReminderListWidget.swift
//  GeoRemind
//
//  Created by Osama Afaque on 20/12/2025.
//

import SwiftUI

struct RemindersListView: View {
    var reminders: [Reminder]
    var appCoordinator: AppCoordinator
    var onDelete: (Int) -> Void

    var body: some View {
        if reminders.isEmpty {
            EmptyReminderState(appCoordinator: appCoordinator)
        } else {
            LazyVStack(spacing: 12) {
                ForEach(reminders.indices, id: \.self) { index in
                    
                    ReminderRow(reminder: reminders[index], identifier: reminders[index].identifier , onRowTap: {
                        appCoordinator.showReminderDetail(reminder: reminders[index])
                    }, onBtnTap: {
                        let identifier = reminders[index].identifier
                        
                        CoreDataManager.shared.deleteReminder(withIdentifier: identifier){ deletedIndex in
                            if let index = deletedIndex {
                                onDelete(index)
                            }
                        }
                    })
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                        .contentShape(Rectangle()) 
                }
            }
            .padding(.horizontal)
        }
    }
}

