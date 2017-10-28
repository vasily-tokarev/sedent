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

enum WorkoutErrors: Error {
    case timerNotSet
}

let notifications: Notifications = Notifications()

class State: Codable {
    var settings: [Settings] = DataManager().saved()
    var exercises: [Exercise] = DataManager().saved()
    var workouts: [Workout] = DataManager().saved()
    var enabledExercises: [EnabledExercise] = DataManager().saved()
}

var state = State()

func firstRun() {
    if state.settings.count == 0 {
        state.settings = []
//        state.settings.append(Settings(notificationInterval: 40.0, workoutDuration: 2.0, notificationText: "It is time to move!", autostart: false))
        state.settings.append(Settings(notificationInterval: 0.2, workoutDuration: 2.0, notificationText: "It is time to move!", autostart: false, dateNotificationCreated: Date(), notificationSwitchIsOn: false))
        let _ = state.settings.save()
    }
}

class Settings: Codable {
    var notificationInterval: Double
    var dateNotificationCreated: Date
    var notificationSwitchIsOn: Bool
    var workoutDuration: Double
    var autostart: Bool
    var notificationText: String
//    let timerOffAt: Date = Date() // Do I need it really?
    var notificationIntervalInSeconds: Double {
        return self.notificationInterval * 60
    }
    var workoutDurationInSeconds: Int {
        return Int(self.workoutDuration * 60)
    }

    init(notificationInterval: Double, workoutDuration: Double, notificationText: String, autostart: Bool, dateNotificationCreated: Date, notificationSwitchIsOn: Bool) {
        self.notificationInterval = notificationInterval
        self.workoutDuration = workoutDuration
        self.notificationText = notificationText
        self.autostart = autostart
        self.dateNotificationCreated = dateNotificationCreated
        self.notificationSwitchIsOn = notificationSwitchIsOn
    }
}

class Coach {
    var coachViewDelegate: CoachViewController?
    var mainViewDelegate: ViewController?
    let speechSynthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    var exercises: [Exercise] { return workout.exercises }
    var currentExercise: Exercise
    var currentExerciseIndex: Int { return workout.exercises.index(of: currentExercise)! }
//    var currentExerciseDuration: Int { return currentExercise.duration }
    var currentExerciseDuration: Int { return 3 }
    var secondsSinceExerciseStarted: Int { return Int(Date().timeIntervalSince(exerciseStarted!)) }
    var workout: Workout
    var totalDuration: Int?
//    var durationLeft: Int?

    var timer: Timer?
    var exerciseStarted: Date?

    func speaker(say speech: String) {
        let speech = AVSpeechUtterance(string: speech)
        DispatchQueue.main.async(execute: {
            self.speechSynthesizer.speak(speech)
        })
    }

    func stop() throws {
        // https://stackoverflow.com/questions/44633729/stop-a-dispatchqueue-that-is-running-on-the-main-thread
        print("stopping workout")

        guard let timer = timer else {
            print("Workout: timer is not set")
            throw WorkoutErrors.timerNotSet
        }

        timer.invalidate()
    }

    func start(workout: Workout) {
        notifications.center.removeAllDeliveredNotifications()

//        exercises = workout.exercises.reversed()
        print("workout.description: \(workout.description)")
        print("exercises.count: \(exercises.count)")

        guard let currentExercise = exercises.first else {
            print("currentExercise is not set")
            print("workout: \(workout)")
            print("workout.exercises.count: \(workout.exercises.count)")
            return
        }


        totalDuration = exercises.duration

        exercises.forEach { e in
            print("e.id: \(e.id)")
            print("e.name: \(e.name)")
        }
        print("currentExercise.name: \(currentExercise.name)")

        self.startTimer()
        speaker(say: currentExercise.speech!.start!)
        exerciseStarted = Date()
    }

    @objc func updateTimer() {
        guard let exerciseStarted = exerciseStarted else {
            print("Coach.updateTimer(): exerciseStarted is not set.")
            return
        }
        let secondsLeft = (currentExerciseDuration - secondsSinceExerciseStarted) % 60
        let minutesLeft = ((currentExerciseDuration - secondsSinceExerciseStarted) / 60)

        if secondsLeft < 0 {
            self.coachViewDelegate!.updateLabel(with: "0:00")
        } else {
            self.coachViewDelegate!.updateLabel(with: String(format: "%02i:%02i", Int(minutesLeft), Int(secondsLeft)))
        }

//        switch secondsLeft {
//        case 30:
//            speaker(say: currentExercise.speech!.thirtySecondsLeft!)
//        case 10:
//            speaker(say: currentExercise.speech!.tenSecondsLeft!)
//        case 5:
//            speaker(say: currentExercise.speech!.fiveSecondsLeft!)
//        case 0:
//            speaker(say: currentExercise.speech!.end!)
//        default:
//            break
//        }

        if Int(secondsSinceExerciseStarted) > currentExerciseDuration {
            // Time is up, complete the exercise.
            if currentExercise == workout.exercises.last {
                // perform last one and quit
                self.timer!.invalidate()
                coachViewDelegate?.performSegueToReturnBack()
//                mainViewDelegate?.workoutCompleted = true
            } else {
                self.currentExercise = workout.exercises[self.currentExerciseIndex+1]
                coachViewDelegate!.exerciseChanged()
                self.exerciseStarted = Date()
                print(Int(Date().timeIntervalSince(exerciseStarted)))

                self.timer!.invalidate()
                self.startTimer()
//                speaker(say: currentExercise.speech!.start!)
            }
        }
    }

    func startTimer() {
        if self.timer != nil {
            self.timer!.invalidate()
        } // or just invalidate it in any case?
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }

    init() {
        print("init")
//        self.workout = state.workouts.next
        state.workouts.refresh()
        self.workout = state.workouts.first!
        print("init 1")
        if let currentExercise = self.workout.exercises.first {
            self.currentExercise = currentExercise
        } else {
            print("Coach init failed: currentExercise is not set")
            self.currentExercise = Exercise()
        }
    }
}

class Exercise: Codable, Equatable {
    let id: Int?
    var name: String? = "Exercise"
    var duration: Int = 60
//    var image: UIImage? = nil
    var speech: Speech?
    var description: String?

    init(id: Int? = nil, name: String? = nil, duration: Int? = nil, speech: Speech? = nil, description: String? = "") {
        if state.exercises.count > 0 {
            self.id = state.exercises.count + 1
        } else {
            self.id = 0
        }

        self.name = name

        if let duration = duration {
            self.duration = duration
        }

        if let speech = speech {
            self.speech = speech
        }

        if let description = description {
            self.description = description
        }
    }

    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id
    }

    struct Speech: Codable {
        var start: String?
        var thirtySecondsLeft: String?
        var tenSecondsLeft: String?
        var fiveSecondsLeft: String?
        var end: String?

        init(start: String? = "", thirtySecondsLeft: String? = "", tenSecondsLeft: String? = "", fiveSecondsLeft: String? = "", end: String? = "") {
            self.start = start
            self.thirtySecondsLeft = thirtySecondsLeft
            self.tenSecondsLeft = tenSecondsLeft
            self.fiveSecondsLeft = fiveSecondsLeft
            self.end = end
        }
    }
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
        case is EnabledExercise.Type: pathString = "enabled_exercises"
        case is Settings.Type: pathString = "user_settings"
        default: print("DataManager: No such type.")
        }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                .appendingPathComponent(pathString!).appendingPathExtension("plist")
    }

    func saved() -> [Element] {
        var data: [Element] = []
        if let retrievedData = try? Data(contentsOf: dataURL),
           let decodedData = try?
           propertyListDecoder.decode([Element].self, from: retrievedData) {
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

extension Array where Element: Settings {
    private var manager: DataManager<Settings> { return DataManager() }

    var saved: [Settings] {
        state.settings = manager.saved()
        return state.settings
    }

    func save() -> Bool {
        state.settings = self
        return manager.save(data: self)
    }
}

extension Array where Element: Exercise {
    private var manager: DataManager<Exercise> { return DataManager() }

    var saved: [Exercise] {
        state.exercises = manager.saved()
        return state.exercises
    }

    func save() -> Bool {
        state.exercises = self
        return manager.save(data: self)
    }

    func findBy(id: Int) -> Exercise {
        return self.filter { $0.id == id }[0]
    }

    var duration: Int {
        return self.reduce(0, { duration, exercise in
            return exercise.duration + duration
        })
    }
}

extension Array where Element: EnabledExercise {
    private var manager: DataManager<EnabledExercise> { return DataManager() }

    var saved: [EnabledExercise] {
        state.enabledExercises = manager.saved()
        return state.enabledExercises
    }

    func save() -> Bool {
        state.enabledExercises = self
        state.workouts = []
        state.workouts.arrange(exercises: (exercisesUsed: [], exercisesLeft: self))
        // Less code vs exlicity?
        return manager.save(data: self)
    }

//    func delete(exercise: Exercise) -> [EnabledExercise] {
//        state.enabledExercises = state.enabledExercises.filter { $0.exerciseId != exercise.id}
//        workouts.arrange(exercises: (exercisesUsed: [], exercisesLeft: state.enabledExercises)) // Add a typealias for this.
//        return state.enabledExercises
//    }
}

typealias SortedExercisesTuple = (exercisesUsed: [EnabledExercise], exercisesLeft: [EnabledExercise])

extension Array where Element: Workout {
    private var manager: DataManager<Workout> { return DataManager() }

    var next: Workout { return self.filter { $0.next == true }[0] }

    var saved: [Workout] {
        state.workouts = manager.saved()
        return state.workouts
    }

    func save() -> Bool {
        state.workouts = self
        return manager.save(data: self)
    }

    func findBy(id: Int) -> Workout {
        return self.filter { $0.id == id }[0]
    }

    func refresh() {
        self.arrange(exercises: (exercisesUsed: [], exercisesLeft: state.enabledExercises))
    }

    private func arrange(exercises: SortedExercisesTuple) {
        // Might recurse if duration is too small.
        var duration = Int(state.settings[0].workoutDurationInSeconds)

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
        state.workouts.append(Workout(next: true, enabledExercises: sortedExercises.exercisesUsed))
        if sortedExercises.exercisesLeft.count > 0 {
            state.workouts.arrange(exercises: (exercisesUsed: [], exercisesLeft: sortedExercises.exercisesLeft))
        } else {
            state.workouts.save()
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

class EnabledExercise: Codable, Equatable {
    let id: Int
    let exerciseId: Int
    var workoutId: Int?
    let name: String
    var duration: Int { return state.exercises.filter { $0.id == exerciseId
    }[0].duration }

    init(workoutId: Int?, exerciseId: Int, name: String) {
        self.exerciseId = exerciseId
        if workoutId != nil {
            self.workoutId = workoutId
        }
        self.name = name
        self.id = state.enabledExercises.count + 1
    }

    static func == (lhs: EnabledExercise, rhs: EnabledExercise) -> Bool{
        return lhs.id == rhs.id
    }
}

class Workout: Codable {
    let id: Int
    var next: Bool = false
    var enabledExercises: [EnabledExercise]?
    var exercises: [Exercise] {
        return self.enabledExercises!.flatMap { enabledExercise in
            return state.exercises.filter { exercise in
                return exercise.id == enabledExercise.exerciseId
            }
        }
    }
    let reminder: Int = testMode ? 3 : 30 // delete

    var duration: Int {
        return self.enabledExercises!.reduce(0, { duration, enabledExercise in
            let exercise = exercises.filter { $0.id == enabledExercise.exerciseId
            }[0]
            return exercise.duration + duration
        })
    }

    var description: String {
        return "Workout: #\(self.id), next?: \(self.next), exercises.count: \(self.exercises.count), enabledExercises.count: \(self.enabledExercises!.count)"
    }

    init(next: Bool, enabledExercises: [EnabledExercise]) {
        // https://stackoverflow.com/questions/32332985/how-to-use-audio-in-ios-application-with-swift-2
        self.next = next
        self.enabledExercises = enabledExercises
//        self.exercises = exercises
        self.id = state.workouts.count + 1

        self.enabledExercises!.forEach { exercise in
            exercise.workoutId = self.id
        }

    }
}

