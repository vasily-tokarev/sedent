//
//  ViewController.swift
//  Sedentary
//
//  Created by vt on 10/3/17.
//  Copyright © 2017 Vasiliy Tokarev. All rights reserved.
//

import UIKit
import UserNotifications
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var exerciseNotificationSwitch: UISwitch!
    @IBOutlet weak var exerciseTimerLabel: UILabel!
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if exerciseNotificationSwitch.isOn {
            Exercises(ids: [1, 2]).start()
            // Fetch current exercise.
        }
    }
    
    @IBAction func exerciseNotificationSwitchValueChanged(_ sender: UISwitch) {
        if exerciseNotificationSwitch.isOn {
            setupNotifications()
            createNotification()
            startTimer()
        } else {
            exerciseTimerLabel.text = "00:00"
            timer.invalidate()
            // TODO: Remove pending notification if any.
        }
    }
    
    var timer: Timer = Timer()
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
    }
    
    func restartTimer() {
        timer.invalidate()
        startTimer()
    }
    
    @objc func updateTimer() {
        let secondsSinceNotificationCreated = Date().timeIntervalSince(dateNotificationCreated!)
        let secondsLeft = (Int(timeInterval) - Int(secondsSinceNotificationCreated)) % 60
        let minutesLeft = ((Int(timeInterval) - Int(secondsSinceNotificationCreated)) / 60)
        exerciseTimerLabel.text = String(format: "%02i:%02i", Int(minutesLeft), Int(secondsLeft))
        if secondsSinceNotificationCreated > timeInterval {
            timer.invalidate()
            startButton.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // if timer started = timer falue else timer default value
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

