//
//  Notifications.swift
//  Sedentary
//
//  Created by vt on 10/4/17.
//  Copyright © 2017 Vasiliy Tokarev. All rights reserved.
//

import Foundation

import Foundation
import UserNotifications

// Timer
//let timeInterval = 1.0
let timeInterval = testMode ? 1.0 : 2400.0
var trigger: UNNotificationTrigger?
var dateNotificationCreated: Date?

// Notifications
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
            // Notifications not allowed
        }
    }
}

func createNotification() {
    dateNotificationCreated = Date()
    let content = UNMutableNotificationContent()
    content.title = "Exercise"
    content.body = "It is time to move!"
    content.sound = UNNotificationSound.default()
    trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval,
                                                repeats: false)
    
    let identifier = "UYLLocalNotification"
    //    print(timeInterval)
    print(trigger)
    let request = UNNotificationRequest(identifier: identifier,
                                        content: content, trigger: trigger)
    //    print(trigger.nextTriggerDate()?.timeIntervalSince(date))
    center.add(request, withCompletionHandler: { (error) in
        if let error = error {
            // Something went wrong
        }
    })
}
