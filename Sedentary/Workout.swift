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

var exercises: [Exercise] = DataManager().saved()
var workouts: [Workout] = []
let workoutsManager: WorkoutsManager = WorkoutsManager()


class SettingsManager {
    let notificationInterval: Int = 120
    let workoutDuration: Int = 2 // or seconds?
    let timerOffAt: Date = Date()
}

// I'll name you Coach!
class WorkoutsManager {
    let speechSynthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    var workouts: [Workout] = []
    var exercises: [Exercise] = []

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
        let workout = workouts.first
        let lastExerciseId = exercises.last!.id
        _ = exercises.reduce(0, { duration, exercise in
            dispatchSpeaker(say: exercise.speech!.start!, seconds: duration) // 0, 6
//            dispatchSpeaker(say: exercise.speech!.start!, seconds: duration) // 0, 6
            dispatchSpeaker(say: "30 seconds left", seconds: (exercise.duration - (exercise.duration / (exercise.duration / workout!.reminder))) + duration)
            if exercise.id == lastExerciseId {
                dispatchSpeaker(say: "Back to work", seconds: duration + exercise.duration)
                // Restart timer in MainTableViewController
            }
            return duration + exercise.duration
        })
        // delay
    }
}

class Exercise: Codable {
    let savePath: String = "exercises"
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

struct DataManager<Element> {
    // Constraint types with a protocol?
    let propertyListEncoder = PropertyListEncoder()
    let propertyListDecoder = PropertyListDecoder()

    var dataURL: URL {
        var pathString: String?
        switch Element.self {
        case is Exercise.Type: pathString = "exercises"
        case is Workout.Type: pathString = "workouts"
        default: print("No such type")
        }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                .appendingPathComponent(pathString!).appendingPathExtension("plist")
    }

    func saved() -> [Element] {
        var data: [Element] = []
        if let retrievedExercisesData = try? Data(contentsOf: dataURL),
           let decodedData = try?
           propertyListDecoder.decode([Element].self, from: retrievedExercisesData) {
            data = decodedData
        }
        return data
    }

    func save(data: [Element]) -> Bool {
        let encodedData = try? propertyListEncoder.encode(data)
        if let _ = try? encodedData?.write(to: dataURL, options: .noFileProtection) {
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
}

extension Array where Element: Exercise {
    private var manager: DataManager<Exercise> { return DataManager() }
    var saved: [Exercise] {
        exercises = manager.saved()
        return exercises
    }
    func save() -> Bool {
        exercises = self
        return manager.save(data: self)
    }
}

extension Array where Element: Workout {
    private var manager: DataManager<Workout> { return DataManager() }
    var saved: [Workout] {
        workouts = manager.saved()
        return workouts
    }
    func save() -> Bool {
        workouts = self
        return manager.save(data: self)
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
//            let _ = save(data: workouts)
        }

//        if workouts.count > 0 && workouts.last!.timeAt < SettingsManager().timerOffAt {
//            exercises = exercises.reduce(SettingsManager().workoutDuration, { duration, exercise in
//                return duration - exercise.duration!
//            })
//        }
    }
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

class Workout: Codable {
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
    }
}

