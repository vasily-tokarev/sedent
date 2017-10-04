//
//  Exercises.swift
//  Sedentary
//
//  Created by vt on 10/4/17.
//  Copyright © 2017 Vasiliy Tokarev. All rights reserved.
//

import Foundation
import AVFoundation

struct Exercise {
    let id: Int
    var duration: Int
    var name: String
    var speech: String
    //    var description: String
}

struct Exercises {
    let reminder: Int = testMode ? 3 : 30
    let delayBeforeExercise: Int = 1
    let speechSynthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    var count: Int = 0
    //    var currentExerciseName: String
    //    var totalDuration: Int = 0
    var exercises: [Exercise] = []
    let defaultExercises: [Exercise]
    
    init(ids: [Int]) {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback) // not working
        // https://stackoverflow.com/questions/32332985/how-to-use-audio-in-ios-application-with-swift-2
        
        if testMode {
            defaultExercises = [
                Exercise(id: 1, duration: 6, name: "Surya Namaskar", speech: "Surya Namaskar 1 minute"),
                Exercise(id: 2, duration: 6, name: "Headstanding", speech: "Headstanding 1 minute")
            ]
        } else {
            defaultExercises = [
                Exercise(id: 1, duration: 60, name: "Surya Namaskar", speech: "Surya Namaskar 1 minute"),
                Exercise(id: 2, duration: 60, name: "Headstanding", speech: "Headstanding 1 minute")
            ]
        }
        
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
            dispatchSpeaker(say: exercise.speech, seconds: duration) // 0, 6
            print("exercise.duration: \(exercise.duration)")
            
            dispatchSpeaker(say: "30 seconds left", seconds: (exercise.duration - (exercise.duration / (exercise.duration / reminder))) + duration)
            if exercise.id == lastExerciseId {
                dispatchSpeaker(say: "Back to work", seconds: duration + exercise.duration)
                // Restart timer in MainTableViewController
            }
            return duration + exercise.duration
        })
        // delay
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
    
    func addExercise() {
        // Implement later.
    }
    
    func removeExercise() {
        // Implement later.
    }
    
    func editExercise() {
        // Implement later.
    }
}

