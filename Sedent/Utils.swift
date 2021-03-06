//
//  Configuration.swift
//  Sedent
//
//  Created by vt on 10/4/17.
//  Copyright © 2017 Vasiliy Tokarev. All rights reserved.
//

import Foundation

let testMode: Bool = false

enum Navigation {
    enum Segue: String {
        case workoutsExercisesToExercises
        case collapsibleToBoards
        case mainToWorkouts

        case unwindToWorkoutsExercises
        var identifier: String {
            switch self {
            case .workoutsExercisesToExercises:
                return "WorkoutsExercisesToExercises"
            case .collapsibleToBoards:
                return "CollapsibleToBoards"
            case .mainToWorkouts:
                return "MainToWorkouts"
            case .unwindToWorkoutsExercises:
                 return "unwindToWorkoutsExercises"
            }
        }
    }
    enum ExercisesTableViewController {
        enum Section: Int {
            case image
            var number: Int {
                switch self {
                case .image:
                    return 2
                }
            }
        }
    }
    enum WorkoutsExercisesTableViewController {
        enum Cell {
//          enum Cell: String {
//            case newExercise
//            case editExercise
//            var name: String {
//                switch self {
//                case .newExercise:
//                    return "New Exercise"
//                case .editExercise:
//                    return "Edit Exercise"
//                }
//            }
            enum Identifier: String {
                case workoutsExercisesCell
                var identifier: String {
                    switch self {
                    case .workoutsExercisesCell:
                        return "WorkoutsExercisesCell"
                    }
                }
            }
        }
        enum Section: Int {
            case workouts
            case exercises
            case newExercise
            var number: Int {
                switch self {
                case .workouts:
                    return 0
                case .exercises:
                    return 1
                case .newExercise:
                    return 2
                }
            }
            var name: String {
                switch self {
                case .workouts:
                    return "Workouts"
                case .exercises:
                    return "Exercises"
                case .newExercise:
                    return ""
                }
            }
        }
    }
}

