//
//  ExerciseViewController.swift
//  Sedentary
//
//  Created by vt on 10/19/17.
//  Copyright © 2017 Vasiliy Tokarev. All rights reserved.
//

import UIKit

class ExerciseViewController: UIViewController {
    @IBOutlet weak var exerciseTimerLabel: UILabel!
    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var exerciseImageView: UIImageView!

    let coach: Coach = Coach()
    var dateNotificationCreated: Date?
    var exerciseTimer: Timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ExerciseViewDidLoad")

//        if exerciseNotificationSwitch.isOn {

        dateNotificationCreated = Date()
        coach.delegate = self
        coach.startWorkout()
        // Do any additional setup after loading the view.
    }

//    @objc func updateTimer() {
    @objc func updateTimer() {
        print("updateTimer")
        let timeInterval = coach.currentExercise!.duration
        // exerciseName
        let secondsSinceNotificationCreated = Date().timeIntervalSince(dateNotificationCreated!)
        let secondsLeft = (Int(timeInterval) - Int(secondsSinceNotificationCreated)) % 60
        let minutesLeft = ((Int(timeInterval) - Int(secondsSinceNotificationCreated)) / 60)
        exerciseTimerLabel.text = String(format: "%02i:%02i", Int(minutesLeft), Int(secondsLeft))
//        if secondsSinceNotificationCreated > Int(timeInterval) {
//            exerciseTimer.invalidate()
//            startButton.isEnabled = true
//        }
    }

    func startTimer() {
        exerciseTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ExerciseViewController.updateTimer), userInfo: nil, repeats: true)
    }

    func restartTimer() {
        exerciseTimer.invalidate()
        startTimer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
