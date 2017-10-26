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

//ViewControllerError.dateNotificationCreatedNotSet
enum ViewControllerError: Error {
    case dateNotificationCreatedNotSet
}

class ViewController: UIViewController {
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var exerciseNotificationSwitch: UISwitch!
    @IBOutlet weak var exerciseTimerLabel: UILabel!

    var workoutCompleted: Bool = false

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
        } else {
            exerciseTimerLabel.text = "00:00"
            timer.invalidate()
            // TODO: Remove pending notification if any.
        }
    }

    var timer: Timer = Timer()

    func startTimer() {
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
            timer.invalidate()
            startButton.isEnabled = true
        }
    }

    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("tap working")
        performSegue(withIdentifier: "ViewToTimePicker", sender: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view will appear!")

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
        coach.mainViewDelegate = self

        print("state.enabledExercises.count: \(state.enabledExercises.count)")
        state.workouts.arrange(exercises: (exercisesUsed: [], exercisesLeft: state.enabledExercises))
        print("arranged")

        self.navigationItem.title = "Sedentary"

        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapFunction))
        exerciseTimerLabel.isUserInteractionEnabled = true
        exerciseTimerLabel.addGestureRecognizer(tap)
        print("view loaded")

        // if timer started = timer false else timer default value

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

