//
//  ReminderListWidget.swift
//  GeoRemind
//
//  Created by Osama Afaque on 20/12/2025.
//

import SwiftUI

struct RemindersListView: View {
    @Binding var reminders: [Reminder]
    var appCoordinator: AppCoordinator

    var body: some View {
        if reminders.isEmpty {
            EmptyReminderState(appCoordinator: appCoordinator)
        } else {
            LazyVStack(spacing: 12) {
                ForEach(reminders.indices, id: \.self) { index in
//                    ReminderRow(reminder: $reminders[index], id: reminders[index].id) {
//                        reminders.removeAll(where: {$0.id == reminders[index].id})
//                    }
                    
                    ReminderRow(reminder: $reminders[index], identifier: reminders[index].identifier , onRowTap: {
                        appCoordinator.showReminderDetail(reminder: reminders[index])
                    }, onBtnTap: {
                        if let index = reminders.firstIndex(where: {$0.identifier == reminders[index].identifier}) {
                            reminders.remove(at: index)
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

    // MARK: - Helpers

//    private func binding(for reminder: Reminder) -> Binding<Reminder> {
//        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else {
//            fatalError("Reminder not found")
//        }
//        return $reminders[index]
//    }
//
//    private func delete(reminder: Reminder) {
//        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
//            reminders.remove(at: index)
//        }
//    }
}

