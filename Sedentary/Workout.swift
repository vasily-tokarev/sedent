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

struct Exercise {
    let id: Int
    var name: String
    var duration: Int
    var image: UIImage
    struct Speech {
        var start: String
        var speechThirty: String
        var speechTen: String
        var speechFive: String
        var speechLast: String
    }
    var description: String
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
    var exercises: [Exercise] = [Exercise(id: 1, duration: 60, name: "Surya Namaskar", speech: "Surya Namaskar 1 minute"),
                                   Exercise(id: 2, duration: 60, name: "Headstanding", speech: "Headstanding 1 minute")]
    let defaultExercises: [Exercise] = [Exercise(id: 1, duration: 6, name: "Surya Namaskar", speech: "Surya Namaskar 1 minute"),
                                        Exercise(id: 2, duration: 6, name: "Headstanding", speech: "Headstanding 1 minute")]
    
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
            workoutFunctions.dispatchSpeaker(say: exercise.speech, seconds: duration) // 0, 6
            print("exercise.duration: \(exercise.duration)")
            
            workoutFunctions.dispatchSpeaker(say: "30 seconds left", seconds: (exercise.duration - (exercise.duration / (exercise.duration / reminder))) + duration)
            if exercise.id == lastExerciseId {
                workoutFunctions.dispatchSpeaker(say: "Back to work", seconds: duration + exercise.duration)
                // Restart timer in MainTableViewController
            }
            return duration + exercise.duration
        })
        // delay
    }
}

