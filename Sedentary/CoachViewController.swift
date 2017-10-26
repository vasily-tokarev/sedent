//
//  CoachViewController.swift
//  Sedentary
//
//  Created by vt on 10/19/17.
//  Copyright © 2017 Vasiliy Tokarev. All rights reserved.
//

import UIKit

class CoachViewController: UIViewController {
    @IBOutlet weak var exerciseTimerLabel: UILabel!
    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var exerciseImageView: UIImageView!

//    let coach: Coach = state.coach
    var dateNotificationCreated: Date?
//    var exerciseTimer: Timer = Timer()
    var exerciseTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        dateNotificationCreated = Date()
        coach.delegate = self
        coach.start()
        updateExerciseName()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        do {
            try coach.stop()
        } catch {
            print("error \(error)")
        }
    }

    func performSegueToReturnBack()  {
        // Pass workout complete to main view and restart the timer.
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func updateExerciseName() {
        exerciseNameLabel.text = coach.currentExercise?.name
    }

    func exerciseChanged() {
        updateExerciseName()
        dateNotificationCreated = Date()
    }

    func updateLabel(with text: String) {
        exerciseTimerLabel.text = text
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
