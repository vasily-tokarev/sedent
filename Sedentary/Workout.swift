//
//  Exercises.swift
//  Sedentary
//
//  Created by vt on 10/4/17.
//  Copyright © 2017 Vasiliy Tokarev. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

//var exercises: [Exercise] = []
//var workouts: [Workout] = []
var exercisesManager = ExercisesManager()
//var exercises = exercisesManager.exercises
var workoutsManager = WorkoutsManager()

class DataManager {
    let propertyListEncoder = PropertyListEncoder()
    let propertyListDecoder = PropertyListDecoder()

//    func dataURL() -> URL {
    // Implement in subclass.
//    }


}

// MAKE IT RIGHT! Protocols? Aliases? Extensions?
// Make it simple? Just use [Exercise] variable and functions.

class SettingsManager: DataManager {
    let notificationInterval: Int = 120
    let workoutDuration: Int = 2 // or seconds?
    let timerOffAt: Date = Date()
}

class ExercisesManager: DataManager {
    let dataURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("exercises").appendingPathExtension("plist")
    var exercises: [Exercise] = []

    func data() -> [Exercise] {
        var data: [Exercise] = []
        if let retrievedExercisesData = try? Data(contentsOf: dataURL),
           let decodedExercises = try?
           propertyListDecoder.decode(Array<Exercise>.self, from: retrievedExercisesData) {
            data = decodedExercises
        }
        exercises = data
        return exercises
    }

    func save(data: [Exercise]) -> Bool {
        print("saving ExerciseManager")
        let encodedData = try? propertyListEncoder.encode(data)
        if let _ = try? encodedData?.write(to: dataURL, options: .noFileProtection) {
            exercises = data
            return true
        } else {
            return false
        }
    }

    func removeAll() -> Bool {
        if let _ = try? FileManager().removeItem(at: dataURL) {
            return true
        } else {
            return false
        }
    }

    override init() {
        super.init()
        var data: [Exercise] = []
        if let retrievedExercisesData = try? Data(contentsOf: dataURL),
           let decodedExercises = try?
           propertyListDecoder.decode(Array<Exercise>.self, from: retrievedExercisesData) {
            data = decodedExercises
        }
        exercises = data
//        exercises = data()
    }
}

class WorkoutsManager: DataManager {
    let speechSynthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    let dataURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("workout").appendingPathExtension("plist")
    var workouts: [Workout] = []
    var exercises: [Exercise] = []

    func data() -> [Workout] {
        var data: [Workout] = []
        if let retrievedExercisesData = try? Data(contentsOf: dataURL),
           let decodedExercises = try?
           propertyListDecoder.decode(Array<Workout>.self, from: retrievedExercisesData) {
            data = decodedExercises
        }
        workouts = data
        return workouts
    }

    func save(data: [Workout]) -> Bool {
        let encodedData = try? propertyListEncoder.encode(data)
        if let _ = try? encodedData?.write(to: dataURL, options: .noFileProtection) {
            workouts = data
            return true
        } else {
            return false
        }
    }

    func removeAll() -> Bool {
        if let _ = try? FileManager().removeItem(at: dataURL) {
            return true
        } else {
            return false
        }
    }

    func arrange() {
        // Returns arranged workouts with timeAt and exercises.
        // Exercises in input order with duration less than workout duration.
        //

        if workouts.count == 0 {
            // New workout with exercises with total duration less than settings duration.
            var durationLeft = SettingsManager().workoutDuration
            exercises = exercises.flatMap { exercise in
                durationLeft -= exercise.duration
                // Total duration might be more, restrict it somehow.
                if durationLeft > 0 {
                    return exercise
                } else {
                    return nil
                }
            }
            workouts.append(Workout(exercises: exercises, name: "Test"))
            let _ = save(data: workouts)
        }

//        if workouts.count > 0 && workouts.last!.timeAt < SettingsManager().timerOffAt {
//            exercises = exercises.reduce(SettingsManager().workoutDuration, { duration, exercise in
//                return duration - exercise.duration!
//            })
//        }
    }


    func dispatchSpeaker(say speech: String, seconds: Int = 0) {
        let speech = AVSpeechUtterance(string: speech)
        if seconds == 0 {
            DispatchQueue.main.async(execute: {
                self.speechSynthesizer.speak(speech)
            })
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: {
                self.speechSynthesizer.speak(speech)
            })
        }
    }

    func start() {
        print("workout started start()")
        let workout = workouts.first
        print("workout: \(workout)")
        print("exercises: \(exercises)")
        exercises = exercisesManager.exercises
        let lastExerciseId = exercises.last!.id
        print("1")
        _ = exercises.reduce(0, { duration, exercise in
            print("2")
            dispatchSpeaker(say: exercise.speech!.start!, seconds: duration) // 0, 6
//            dispatchSpeaker(say: exercise.speech!.start!, seconds: duration) // 0, 6
            print("3")
            print("exercise.duration: \(exercise.duration)")

            dispatchSpeaker(say: "30 seconds left", seconds: (exercise.duration - (exercise.duration / (exercise.duration / workout!.reminder))) + duration)
            print("4")
            if exercise.id == lastExerciseId {
                dispatchSpeaker(say: "Back to work", seconds: duration + exercise.duration)
                // Restart timer in MainTableViewController
            }
            return duration + exercise.duration
        })
        // delay
    }

    override init() {
//        workouts = data()
        super.init()
        var data: [Workout] = []
        if let retrievedExercisesData = try? Data(contentsOf: dataURL),
           let decodedExercises = try?
           propertyListDecoder.decode(Array<Workout>.self, from: retrievedExercisesData) {
            data = decodedExercises
        }
        workouts = data
        exercises = exercisesManager.exercises
    }
}

struct Exercise: Codable {
    let id: Int?
    var name: String? = "hello"
    var duration: Int = 60
//    var image: UIImage? = nil
    var speech: Speech?
    var description: String?

    init(id: Int? = nil, name: String? = nil, duration: Int? = nil, speech: Speech? = nil, description: String? = nil) {
        self.id = id // UserExercises.count += DefaultExercises += 1
        self.name = name
        if let duration = duration {
            self.duration = duration
        }
//        self.duration = duration!
        if let speech = speech {
            self.speech = speech
        }
        self.description = description
    }

    struct Speech: Codable {
        var start: String?
        var thirtySecondsLeft: String?
        var tenSecondsLeft: String?
        var fiveSecondsLeft: String?
        var end: String?

        init(start: String? = nil, thirtySecondsLeft: String? = nil, tenSecondsLeft: String? = nil, fiveSecondsLeft: String? = nil, end: String? = nil) {
            self.start = start
            self.thirtySecondsLeft = thirtySecondsLeft
            self.tenSecondsLeft = tenSecondsLeft
            self.fiveSecondsLeft = fiveSecondsLeft
            self.end = end
        }
    }
    // Add `remove` extension which removes both from `exercises` and data (DataManager).
    // https://stackoverflow.com/questions/24938948/array-extension-to-remove-object-by-value
}

struct WorkoutFunctions {
    let speechSynthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()

    func dispatchSpeaker(say speech: String, seconds: Int = 0) {
        let speech = AVSpeechUtterance(string: speech)
        if seconds == 0 {
            DispatchQueue.main.async(execute: {
                self.speechSynthesizer.speak(speech)
            })
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: {
                self.speechSynthesizer.speak(speech)
            })
        }
    }
}

struct Workout: Codable {
//    let workoutFunctions: WorkoutFunctions = WorkoutFunctions()
    let name: String
//    var timeAt: Date
    var exercises: [Exercise]
    let reminder: Int = testMode ? 3 : 30

//    let delayBeforeExercise: Int = 1
//    var count: Int = 0

    init(exercises: [Exercise], name: String) {
        // https://stackoverflow.com/questions/32332985/how-to-use-audio-in-ios-application-with-swift-2
        self.name = name
        self.exercises = exercises
    }

    func start() {
//        let lastExerciseId = exercises.last!.id
//        _ = exercises.reduce(0, { duration, exercise in
//            workoutFunctions.dispatchSpeaker(say: exercise.speech!.start!, seconds: duration) // 0, 6
//            print("exercise.duration: \(exercise.duration)")
//
//            workoutFunctions.dispatchSpeaker(say: "30 seconds left", seconds: (exercise.duration - (exercise.duration / (exercise.duration / reminder))) + duration)
//            if exercise.id == lastExerciseId {
//                workoutFunctions.dispatchSpeaker(say: "Back to work", seconds: duration + exercise.duration)
//                // Restart timer in MainTableViewController
//            }
//            return duration + exercise.duration
//        })
        // delay
    }
}

