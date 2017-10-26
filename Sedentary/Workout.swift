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

let coach: Coach = Coach()
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
        state.settings.append(Settings(notificationInterval: 1.0, workoutDuration: 2.0, notificationText: "It is time to move!", autostart: false))
        state.settings.save()
    }
}

class Settings: Codable {
    var notificationInterval: Double
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

    init(notificationInterval: Double, workoutDuration: Double, notificationText: String, autostart: Bool) {
        self.notificationInterval = notificationInterval
        self.workoutDuration = workoutDuration
        self.notificationText = notificationText
        self.autostart = autostart
    }
}

class Coach {
    var delegate: CoachViewController?
    var mainViewDelegate: ViewController?
    let speechSynthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    var exercises: [Exercise] = []
    var workouts: [Workout] = []
    var currentExercise: Exercise?
    var currentWorkout: Workout?
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
            return
        }

        timer.invalidate()
    }

    func start(exercise: Exercise? = nil) {
        notifications.center.removeAllDeliveredNotifications()
        state.workouts.arrange(exercises: (exercisesUsed: [], exercisesLeft: state.enabledExercises))
        self.workouts = state.workouts
        print("state.workouts.count: \(state.workouts.count)")
        guard self.workouts.count > 0 else {
            print("There are no workouts")
            // Remove the text, add "You have no workouts available" to the exercise name.
            return
        }

        currentWorkout = self.workouts.next
        if exercise == nil {
            currentExercise = currentWorkout?.exercises.first
//            durationLeft = currentWorkout!.exercises.duration
            totalDuration = currentWorkout?.exercises.duration
        }

        guard currentExercise != nil else {
            print("currentExercise is not set")
            return
        }

        print("currentWorkout!.exercises.count: \(currentWorkout?.exercises.count)")

        self.startTimer()

//        self.delegate!.exerciseChanged()
//        durationLeft! -= currentExercise!.duration
    }

    @objc func updateTimer() {
        print("updating timer")
        print("currentExercise: \(self.currentExercise)")
        print("currentExercise duration: \(self.currentExercise!.duration)")
        let timeInterval = self.currentExercise!.duration
        print("timerInterval")
//        let timeInterval = 6

        let secondsSinceNotificationCreated = Date().timeIntervalSince(exerciseStarted!)
        let secondsLeft = (Int(timeInterval) - Int(secondsSinceNotificationCreated)) % 60
        let minutesLeft = ((Int(timeInterval) - Int(secondsSinceNotificationCreated)) / 60)
//        print(String(format: "%02i:%02i", Int(minutesLeft), Int(secondsLeft)))

        print("seconds set")

        if secondsLeft < 0 {
            self.delegate!.updateLabel(with: "0:00")
        } else {
            self.delegate!.updateLabel(with: String(format: "%02i:%02i", Int(minutesLeft), Int(secondsLeft)))
        }

        func doNothing() {}

        print("timerInterval: \(timeInterval)")
        print("secondsLeft: \(secondsLeft)")
        switch secondsLeft {
        case timeInterval - 1:
            speaker(say: currentExercise!.speech!.start!)
        case 30:
            speaker(say: currentExercise!.speech!.thirtySecondsLeft!)
        case 10:
            speaker(say: currentExercise!.speech!.tenSecondsLeft!)
        case 5:
            speaker(say: currentExercise!.speech!.fiveSecondsLeft!)
        case 0:
            speaker(say: currentExercise!.speech!.end!)
        default:
            doNothing()
        }

        if Int(secondsSinceNotificationCreated) > timeInterval {
            if currentWorkout!.exercises.last == currentExercise {
                print("last exercise")
                // if exercise is last - segue back (delegate)
                self.timer!.invalidate()
                delegate?.performSegueToReturnBack()
                mainViewDelegate?.workoutCompleted = true
            } else {
                print("starting timer once again")
                let index = currentWorkout!.exercises.index(of: currentExercise!)!
                currentExercise = currentWorkout!.exercises[index+1]

                exerciseStarted = Date()
                self.startTimer()
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
//        workouts = []
//        state.workouts.arrange(exercises: (exercisesUsed: [], exercisesLeft: state.enabledExercises))
//        self.workouts = state.workouts
//        print("state.workouts.count: \(state.workouts.count)")
        exerciseStarted = Date()
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

    static func == (lhs: Exercise, rhs: Exercise) -> Bool{
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



    func arrange(exercises: SortedExercisesTuple) {
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
//    var timeAt: Date
    var enabledExercises: [EnabledExercise]?
    var exercises: [Exercise] {
        return state.exercises.filter { exercise in
            return self.enabledExercises!.contains { enabledExercise in
                return enabledExercise.exerciseId == exercise.id
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

//    let delayBeforeExercise: Int = 1
//    var count: Int = 0

//    func duration() -> Int {
//        return self.enabledExercises!.reduce(0, { duration, enabledExercise in
//            let exercise = exercises.filter { $0.id == enabledExercise.exerciseId
//            }[0]
//            return exercise.duration + duration
//        })
//    }

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

