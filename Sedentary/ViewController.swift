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

enum ViewControllerError: Error {
    case dateNotificationCreatedNotSet
}

class ViewController: UIViewController {
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var exerciseNotificationSwitch: UISwitch!
    @IBOutlet weak var exerciseTimerLabel: UILabel!

    var workoutCompleted: Bool = false

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: Check the destination.
        let coachVC = segue.destination as? CoachViewController
        coachVC?.delegate = self
    }

    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        print("unwinding")
    }

    @IBAction func startButtonTapped(_ sender: UIButton) {
//        startButton.setTitle("Resume", for: .normal)
    }

    @IBAction func exerciseNotificationSwitchValueChanged(_ sender: UISwitch) {
        if exerciseNotificationSwitch.isOn {
//            createNotification()
            startTimer()
            state.settings[0].notificationSwitchIsOn = true
            state.settings[0].dateNotificationCreated = Date()
        } else {
            state.settings[0].notificationSwitchIsOn = false
            exerciseTimerLabel.text = "00:00"
            exerciseTimerLabel.textColor = .white
            timer.invalidate()
        }
        let _ = state.settings.save()
    }

    var timer: Timer = Timer()

    func resumeTimer() {
        notifications.createNotification(dateNotificationCreated: state.settings[0].dateNotificationCreated)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
    }

    func startTimer() {
        exerciseTimerLabel.textColor = .white
        notifications.createNotification()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
    }

    func restartTimer() {
        timer.invalidate()
        startTimer()
    }

    @objc func updateTimer() throws {
        guard let dateNotificationCreated = notifications.dateNotificationCreated else {
            print("ViewControllerError.dateNotificationCreatedNotSet")
            throw ViewControllerError.dateNotificationCreatedNotSet
        }

        let secondsSinceNotificationCreated = Date().timeIntervalSince(dateNotificationCreated)
        let secondsLeft = (Int(notifications.notificationInterval) - Int(secondsSinceNotificationCreated)) % 60
        let minutesLeft = ((Int(notifications.notificationInterval) - Int(secondsSinceNotificationCreated)) / 60)
        exerciseTimerLabel.text = String(format: "%02i:%02i", Int(minutesLeft), Int(secondsLeft))
        if secondsSinceNotificationCreated > notifications.notificationInterval {
            exerciseTimerLabel.textColor = .red
            exerciseTimerLabel.text = "00:00"
            timer.invalidate()
        }
    }

    @objc func tapFunction(sender:UITapGestureRecognizer) {
        performSegue(withIdentifier: "ViewToTimePicker", sender: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        state.workouts.forEach {
            if $0.next {
                print($0.next)
            }
        }

        if state.settings[0].notificationSwitchIsOn {
            exerciseNotificationSwitch.isOn = state.settings[0].notificationSwitchIsOn
            resumeTimer()
        }

        if self.workoutCompleted && exerciseNotificationSwitch.isOn {
            startTimer()
        }
        self.workoutCompleted = false

//        startTimer()
//        print("timer started")

        let nav = self.navigationController?.navigationBar
//        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.white
        nav?.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Sedentary"

        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapFunction))
        exerciseTimerLabel.isUserInteractionEnabled = true
        exerciseTimerLabel.addGestureRecognizer(tap)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

