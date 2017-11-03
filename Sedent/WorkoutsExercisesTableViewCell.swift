//
//  WorkoutsTableViewCell.swift
//  Sedent
//
//  Created by vt on 10/6/17.
//  Copyright © 2017 Vasiliy Tokarev. All rights reserved.
//

import UIKit

class WorkoutsExercisesTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var workoutTimeLabel: UILabel!
    @IBOutlet weak var nextLabel: UILabel!

    func update(with enabledExercise: EnabledExercise) {
        nameLabel.text = enabledExercise.name

        nextLabel.isHidden = true
        let workouts = state.workouts.filter({ $0.id == enabledExercise.workoutId })
        if workouts.count > 0 {
            let workout = workouts[0]
            if workout.enabledExercises[0].id == enabledExercise.id {
                if workout.next {
                    nextLabel.isHidden = false
                }
                workoutTimeLabel.isHidden = false
//                if let workoutId = enabledExercise.workoutId {
                workoutTimeLabel.textColor = .black
                workoutTimeLabel.text = formatter.secondsToHuman(seconds: workout.duration)
//                    workoutTimeLabel.text = String(state.workouts.findBy(id: workoutId).duration)
//                }
            } else {
                workoutTimeLabel.isHidden = true
            }
        }
    }

    func update(with exercise: Exercise) {
//        print("updating cell with exercise \(exercise.name)")
        nameLabel.text = exercise.name
        workoutTimeLabel.isHidden = false
        nextLabel.isHidden = true

        workoutTimeLabel.text = formatter.secondsToHuman(seconds: exercise.duration)
        if exercise.duration > state.settings[0].workoutDurationInSeconds {
            workoutTimeLabel.textColor = .red
        } else {
            workoutTimeLabel.textColor = .black
        }
    }

    func update(with text: String) {
        nameLabel.text = text
        workoutTimeLabel.isHidden = true
        nextLabel.isHidden = true
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
