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
    @IBOutlet weak var exerciseDescriptionTextView: UITextView!
    
    let coach: Coach = Coach()
    var dateNotificationCreated: Date?
    var exerciseTimer: Timer?
    var delegate: ViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        dateNotificationCreated = Date()
        coach.coachViewDelegate = self
        print("refreshing")
        state.workouts.refresh()
        print("refreshed")
        coach.start(workout: state.workouts.first!)
        print("starting")
        updateView()
        print("updating view")
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
        delegate?.workoutCompleted = true
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
    }

    func updateView() {
        exerciseNameLabel.text = coach.currentExercise.name
        exerciseDescriptionTextView.text = coach.currentExercise.description

        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let imageURL = docDir.appendingPathComponent("\(coach.currentExercise.name)-\(coach.currentExercise.id)-0.png")
//        let imageURL = "\(coach.currentExercise.name)-\(coach.currentExercise.id)-0.png"

        if let data = try? Data(contentsOf: imageURL) {
            exerciseImageView.image = UIImage(data: data)
        }

//        if let image = UIImage(contentsOfFile: imageURL) {
//            exerciseImageView.image = image
//        }
    }

    func exerciseChanged() {
        updateView()
        dateNotificationCreated = Date()
    }

    func updateLabel(with text: String) {
        exerciseTimerLabel.text = text
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
