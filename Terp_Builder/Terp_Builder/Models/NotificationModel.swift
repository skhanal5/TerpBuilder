//
//  NotificationModel.swift
//  Terp_Builder
//
//  Created by caleb on 4/19/23.
//

import Foundation
import UserNotifications

class NotificationModel: ObservableObject {
    
    func getPersission() {
        UNUserNotificationCenter.current().requestAuthorization(options:
            [.alert,.badge,.sound]) { success, error in
            if success {
                print("Notification access given")
            } else if let error = error{
                print(error.localizedDescription)
            }
            
        }
    }
    
    
    func pushNotification(date: Date, title: String, body:String) {
        let trigger: UNNotificationTrigger?
        
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: date)
        trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
