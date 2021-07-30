//
//  NotificationManager.swift
//  CoreEvents
//
//  Created by Ali Dinç on 30/07/2021.
//

import UserNotifications

class NotificationManager: NSObject {
    
    // MARK: - Properties
    static let shared = NotificationManager()
    
    // MARK: - UserNotifications Authorization
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { authorized, error in
            if authorized {
                UNUserNotificationCenter.current().delegate = self
                self.setNotificationCategories()
            } else {
                if let error = error {
                    print("\(error.localizedDescription)")
                }
            }
        }
    }

    private func setNotificationCategories() {
        
        let markAttendedAction = UNNotificationAction(identifier: Constants.markAttendedNotificationActionID, title: Constants.markAttendedTitle, options: UNNotificationActionOptions(rawValue: 0))
        
        let ignoreAction = UNNotificationAction(identifier: Constants.ignoreNotificationActionID, title: Constants.ignoreTitle, options: UNNotificationActionOptions(rawValue: 0))
        
        let category = UNNotificationCategory(identifier: Constants.eventReminderCategoryID, actions: [markAttendedAction, ignoreAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}


extension NotificationManager: UNUserNotificationCenterDelegate {
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.sound, .banner])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.actionIdentifier == Constants.markAttendedNotificationActionID,
           let eventID = response.notification.request.content.userInfo[Constants.eventID] as? String {
            
            EventController.shared.markEventAsAttended(with: eventID)
            completionHandler()
            
        } else if response.actionIdentifier == Constants.ignoreNotificationActionID {
            print("Ignored")
            completionHandler()
        }
    }
}
