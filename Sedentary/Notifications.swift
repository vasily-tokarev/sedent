//
//  Notifications.swift
//  Sedentary
//
//  Created by vt on 10/4/17.
//  Copyright © 2017 Vasiliy Tokarev. All rights reserved.
//

import Foundation
import UserNotifications

class Notifications {
    let notificationInterval = state.settings[0].notificationIntervalInSeconds
    var trigger: UNNotificationTrigger?
    var dateNotificationCreated: Date?

    let center = UNUserNotificationCenter.current()
    let options: UNAuthorizationOptions = [.alert, .sound]

    func setupNotifications() {
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                print("Notifications are not allowed")
            }
        }
    }

    func createNotification(dateNotificationCreated: Date? = nil) {
        if dateNotificationCreated != nil {
            self.dateNotificationCreated = dateNotificationCreated
        } else {
            self.dateNotificationCreated = Date()
            state.settings[0].dateNotificationCreated = self.dateNotificationCreated!
            let _ = state.settings.save()
        }
        let content = UNMutableNotificationContent()
//    content.title = "Notification"
        content.body = state.settings[0].notificationText
        content.sound = UNNotificationSound.default()
        trigger = UNTimeIntervalNotificationTrigger(timeInterval: notificationInterval,
                repeats: false)

        let identifier = "UYLLocalNotification"
        let request = UNNotificationRequest(identifier: identifier,
                content: content, trigger: trigger)
        //    print(trigger.nextTriggerDate()?.timeIntervalSince(date))
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                print("Notifications error: \(error)")
                // Something went wrong
            }
        })
    }

    init() {
        setupNotifications()
    }
}
