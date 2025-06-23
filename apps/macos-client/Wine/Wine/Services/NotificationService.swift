//
//  NotificationService.swift
//  Wine
//
//  Created by Alen Alex on 23/06/25.
//

import Foundation
import UserNotifications
import OSLog

class NotificationService {
    
    private let logger : Logger = Logger(subsystem: AppConstants.reversedDomain, category: "NotificationService")
    
    func scheduleNotification(title: String, subtitle: String, secondsLater: TimeInterval = .zero) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = UNNotificationSound.default
        

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: secondsLater, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString, // A unique ID for this notification
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                self.logger.error("Error scheduling notification: \(error.localizedDescription)")
            } else {
                self.logger.info("Notification scheduled successfully!")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        logger.info( "All notifications removed.")
    }
    
}
