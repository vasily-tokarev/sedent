//
//  Configuration.swift
//  Sedentary
//
//  Created by vt on 10/4/17.
//  Copyright © 2017 Vasiliy Tokarev. All rights reserved.
//

import Foundation

let testMode: Bool = false

public enum CellType: String {
    case newWorkout = "NewWorkout"
    case newExercise = "NewExercise"
}

public enum Segue: String {
    case worksoutsExercisesToWorkouts = "WorksoutsExercisesToWorkouts"
    case worksoutsExercisesToExercises = "WorksoutsExercisesToExercises"
    case collapsibleToBoards = "CollapsibleToBoards"
}

public enum Cell: String {
    case workoutsExercisesCell = "WorkoutsExercisesCell"
}

// Add segues, cells identifiers and rename (file, segues, identifiers).
