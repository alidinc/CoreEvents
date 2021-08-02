//
//  EventScheduler.swift
//  CoreEvents
//
//  Created by Ali Dinç on 30/07/2021.
//

import UserNotifications


class EventScheduler {
    
    
    func cancelNotifications(for event: Event) {
        
        guard let identifer = event.id else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifer])
    }
    
    func scheduleNotifications(for event: Event) {
        guard let identifier = event.id,
              let date = event.date else { return }
        
        cancelNotifications(for: event)
        
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "Are you going to the \(event.name ?? "event")"
        content.sound = .default
        content.userInfo = [Constants.eventID : identifier]
        content.categoryIdentifier = Constants.eventReminderNotificationCategoryID
        
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("\(error.localizedDescription)")
            }
        }
    }
}
