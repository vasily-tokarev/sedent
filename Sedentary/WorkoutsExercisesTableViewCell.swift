//
//  WorkoutsTableViewCell.swift
//  Sedentary
//
//  Created by vt on 10/6/17.
//  Copyright © 2017 Vasiliy Tokarev. All rights reserved.
//

import UIKit

class WorkoutsExercisesTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var workoutTimeLabel: UILabel!

    func update(with workout: Workout) {
        nameLabel.text = workout.name
    }

    func update(with enabledExercise: EnabledExercise) {
        nameLabel.text = enabledExercise.name
        print("enabledExercise.workoutID \(enabledExercise.workoutID)")
        workouts.forEach({ workout in
            workout.enabledExercises!.forEach({exercise in
                print("exercise.workoutID: \(exercise.workoutID)")
            })
        })
        let exerciseWorkouts = workouts.filter({ $0.id == enabledExercise.workoutID })
        if exerciseWorkouts.count > 0 {
            let exerciseWorkout = exerciseWorkouts[0]
            print("exerciseWOrkout: \(exerciseWorkout)")
            if exerciseWorkout.enabledExercises![0].id == enabledExercise.id {
                print("exerciseWorkout.enabledExercises")
                workoutTimeLabel.isHidden = false
                if enabledExercise.workoutID != nil {
                    workoutTimeLabel.text = String(enabledExercise.workoutID!)
                }
            } else {
                workoutTimeLabel.isHidden = true
            }
        }
    }

    func update(with exercise: Exercise) {
        nameLabel.text = exercise.name
        workoutTimeLabel.isHidden = true
    }

    func update(with text: String) {
        nameLabel.text = text
        workoutTimeLabel.isHidden = true
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
