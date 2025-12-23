//
//  ReminderRow.swift
//  GeoRemind
//
//  Created by Osama Afaque on 20/12/2025.
//

import SwiftUI

struct ReminderRow: View {
    @Binding var reminder: Reminder
    @State var identifier : String
    var onRowTap: () -> Void
    var onBtnTap: () -> Void

    
    var body: some View {
        HStack(spacing: 4) {
            
            Image("reminder_icon")
                .resizable()
                .frame(width: 32, height: 32)
                .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.name ?? "")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(reminder.isActive ? .primary : .secondary)
                    .strikethrough(!reminder.isActive)
                
                Text(Utility.shared.getServerDate(date: reminder.dateCreated ?? Date()))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                
                Text(reminder.isActive ? "Pending" : "Completed")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                AppCoordinator.showDeleteReminderAlert() {
                    CoreDataManager.shared.deleteReminder(withIdentifier: identifier){
                        onBtnTap()
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle()) // 🔥 REQUIRED
        .onTapGesture {
            onRowTap()
        }

    }
}

//#Preview {
//    ReminderRow()
//}
