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
var workouts: [Workout] = DataManager().saved()
var enabledExercises: [EnabledExercise] = DataManager().saved()
let workoutsManager: WorkoutsManager = WorkoutsManager()


class SettingsManager {
    let notificationInterval: Int = 120
    let workoutDuration: Int = 120 // or seconds?
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
        case is EnabledExercise.Type: pathString = "enabledExercises"
        default: print("DataManager: No such type.")
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

extension Array where Element: EnabledExercise {
    private var manager: DataManager<EnabledExercise> { return DataManager() }

    var saved: [EnabledExercise] {
        enabledExercises = manager.saved()
        return enabledExercises
    }

    func save() -> Bool {
        enabledExercises = self
        return manager.save(data: self)
    }
}

typealias SortedExercisesTuple = (exercisesUsed: [EnabledExercise], exercisesLeft: [EnabledExercise])

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

    func arrange(exercises: SortedExercisesTuple) {
        var duration = SettingsManager().workoutDuration

        func sortExercises(exercises: SortedExercisesTuple) -> SortedExercisesTuple {
            var sortedExercises: SortedExercisesTuple = (exercisesUsed: [], exercisesLeft: [])
            exercises.exercisesLeft.forEach({ exercise in
                duration -= exercise.duration
                if duration >= 0 {
                    sortedExercises.exercisesUsed.append(exercise)
                } else {
                    sortedExercises.exercisesLeft.append(exercise)
                }
            })
            return sortedExercises
        }

        let sortedExercises = sortExercises(exercises: (exercisesUsed: [], exercisesLeft: exercises.exercisesLeft))
        workouts.append(Workout(next: true, exercises: sortedExercises.exercisesUsed))
        if sortedExercises.exercisesLeft.count > 0 {
            workouts.arrange(exercises: (exercisesUsed: [], exercisesLeft: sortedExercises.exercisesLeft))
        }
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

class EnabledExercise: Codable {
    let id: Int
    let exerciseID: Int
    var workoutID: Int?
    let name: String
    var duration: Int { return exercises.filter { $0.id == exerciseID }[0].duration }

    init(workoutID: Int?, exerciseID: Int, name: String) {
        self.exerciseID = exerciseID
        if workoutID != nil {
            self.workoutID = workoutID
        }
        self.name = name
        if enabledExercises.count > 0 {
            self.id = enabledExercises.count + 1
        } else {
            self.id = 0
        }
    }
}

class Workout: Codable {
    let id: Int
    let name: String? = ""
    var next: Bool = false
//    var timeAt: Date
    var enabledExercises: [EnabledExercise]?
    let reminder: Int = testMode ? 3 : 30 // delete

//    let delayBeforeExercise: Int = 1
//    var count: Int = 0

    func duration() -> Int {
        return self.enabledExercises!.reduce(0, { duration, enabledExercise in
            let exercise = exercises.filter { $0.id == enabledExercise.exerciseID }[0]
            return exercise.duration + duration
        })
    }

    init(next: Bool, exercises: [EnabledExercise]) {
        // https://stackoverflow.com/questions/32332985/how-to-use-audio-in-ios-application-with-swift-2
        self.next = next
        self.enabledExercises = exercises
//        self.exercises = exercises
        if workouts.count > 0 {
            self.id = workouts.count + 1
        } else {
            self.id = 0
        }
        self.enabledExercises!.forEach({ exercise in
            exercise.workoutID = self.id
        })
    }

    func start() {
    }
}

