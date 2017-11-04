//
//  CoachViewController.swift
//  Sedent
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
    
    var coach: Coach = Coach()

    var dateNotificationCreated: Date?
    var exerciseTimer: Timer?
    var delegate: ViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.isIdleTimerDisabled = true
        dateNotificationCreated = Date()
        coach.coachViewDelegate = self

        updateView()
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
        
        if let exerciseId = coach.currentExercise.id {
            let imageURL = docDir.appendingPathComponent("\(coach.currentExercise.name)-\(exerciseId)-0.png")
            
            if let data = try? Data(contentsOf: imageURL) {
                print("got the data")
                exerciseImageView.image = UIImage(data: data)
            }
        }
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
