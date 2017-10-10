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

var exercises: [Exercise] = []
var workouts: [Workout] = []

class DataManager {
    var savedExercises: [Exercise] = []
//    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("exercises").appendingPathExtension("plist")
    let exercisesURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("exercises").appendingPathExtension("plist")
    let propertyListEncoder = PropertyListEncoder()
    let propertyListDecoder = PropertyListDecoder()
    
    func saveExercises(exercises: [Exercise]) -> Bool {
//        let exercisesURL = documentsDirectory.appendingPathComponent("exercises").appendingPathExtension("plist")
        let encodedExercises = try? propertyListEncoder.encode(exercises)
        if let _ = try? encodedExercises?.write(to: exercisesURL, options: .noFileProtection) {
            return true
        } else {
            return false
        }
    }
    
    func readExercises() -> [Exercise] {
        var exercises: [Exercise] = []
//        let exercisesURL = documentsDirectory.appendingPathComponent("exercises").appendingPathExtension("plist")
        if let retrievedExercisesData = try? Data(contentsOf: exercisesURL),
            let decodedExercises = try?
                propertyListDecoder.decode(Array<Exercise>.self, from: retrievedExercisesData) {
            exercises = decodedExercises
        }
        return exercises
    }

    func removeExercises() -> Bool {
        if let _ = try? FileManager().removeItem(at: exercisesURL) {
            return true
        } else {
            return false
        }
    }

    init(exercises: [Exercise]? = nil) {
        if let exercises = exercises {
            let _ = saveExercises(exercises: exercises)
        } else {
            savedExercises = readExercises()
        }
    }
}

struct Exercise: Codable {
    let id: Int?
    var name: String?
    var duration: Int?
//    var image: UIImage? = nil
    var speech: Speech?
    var description: String?
    
    init(id: Int? = nil, name: String? = nil, duration: Int? = nil, speech: Speech? = nil, description: String? = nil) {
        self.id = id // UserExercises.count += DefaultExercises += 1
        self.name = name
        self.duration = duration
        self.speech = speech
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

struct Workout {
    let workoutFunctions: WorkoutFunctions = WorkoutFunctions()
    let name: String
    let reminder: Int = testMode ? 3 : 30
    let delayBeforeExercise: Int = 1
    var count: Int = 0
    //    var currentExerciseName: String
    //    var totalDuration: Int = 0
    var exercises: [Exercise] = [Exercise(id: 1, name: "Surya Namaskar", duration: 60, speech: Exercise.Speech(start: "Surya Namaskar 1 minute"), description: "test"),
                                   Exercise(id: 2, name: "Headstanding", duration: 60, speech: Exercise.Speech(start: "Headstanding 1 minute"), description: "test")]
    let defaultExercises: [Exercise] = [Exercise(id: 1, name: "Surya Namaskar", duration: 6, speech: Exercise.Speech(start: "Surya Namaskar 1 minute"), description: "test"),
                                        Exercise(id: 2, name: "Headstanding", duration: 6, speech: Exercise.Speech(start: "Headstanding 1 minute"), description: "test")]
    
    init(ids: [Int], name: String) {
        // https://stackoverflow.com/questions/32332985/how-to-use-audio-in-ios-application-with-swift-2
        self.name = name
        for _ in ids {
            // How to update current exercise label from here?
            // https://teamtreehouse.com/community/getter-and-setter-methods-swift
            // 1. Assign `exerciseStartedDate`
            // 2. Use code from `start()` to compute current exercise.
            self.exercises = [defaultExercises[0], defaultExercises[1]] // defaultExercises.index { $0.id == 2 }
            //            self.dispatchSpeaker(say: "hello \(id)", seconds: 1)
        }
    }
    
    func start() {
        let lastExerciseId = exercises.last!.id
        _ = exercises.reduce(0, { duration, exercise in
            workoutFunctions.dispatchSpeaker(say: exercise.speech!.start!, seconds: duration) // 0, 6
            print("exercise.duration: \(exercise.duration)")
            
            workoutFunctions.dispatchSpeaker(say: "30 seconds left", seconds: (exercise.duration! - (exercise.duration! / (exercise.duration! / reminder))) + duration)
            if exercise.id == lastExerciseId {
                workoutFunctions.dispatchSpeaker(say: "Back to work", seconds: duration + exercise.duration!)
                // Restart timer in MainTableViewController
            }
            return duration + exercise.duration!
        })
        // delay
    }
}

