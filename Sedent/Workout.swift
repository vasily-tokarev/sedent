//
//  Exercises.swift
//  Sedent
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

var notifications: Notifications = Notifications()

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
        state.settings.append(
                Settings (
                        notificationInterval: 40,
                        workoutDuration: 2.0,
                        notificationText: "It is time to move!",
                        autostart: false,
                        dateNotificationCreated: Date(),
                        notificationSwitchIsOn: false,
                        workoutCompleteSpeech: "Workout completed"
                )
        )
        let _ = state.settings.save()

        func saveImage(image: UIImage, path: URL ) {
            let pngImageData = UIImagePNGRepresentation(image)
            try? pngImageData!.write(to: path)
        }

        let exercises: [(id: Int, name: String, duration: Int, image: String, description: String, startSpeech: String, thirtySecondsLeftSpeech: String, tenSecondsLeftSpeech: String, fiveSecondsLeftSpeech: String, endSpeech: String)] = [
            (id: 1, name: "Leg Raise",
                    duration: 60,
                    image: "leg-raise-1.png",
                    description: "Leg raises are often used to strengthen the rectus abdominis muscle and the internal and external oblique muscles.",
                    startSpeech: "Leg Raise 1 minute",
                    thirtySecondsLeftSpeech: "30 seconds left",
                    tenSecondsLeftSpeech: "10 seconds left",
                    fiveSecondsLeftSpeech: "5 seconds left",
                    endSpeech: "Exercise completed"),
            (id: 2,
                    name: "Plank",
                    duration: 60,
                    image: "plank-2.png",
                    description: "The plank (also called a front hold, hover, or abdominal bridge) is an isometric core strength exercise that involves maintaining a position similar to a push-up for the maximum possible time.",
                    startSpeech: "Plank 1 minute",
                    thirtySecondsLeftSpeech: "30 seconds left",
                    tenSecondsLeftSpeech: "10 seconds left, hold it!",
                    fiveSecondsLeftSpeech: "Almost done!",
                    endSpeech: "Exercise completed"),
            (id: 3,
                    name: "Run In Place",
                    duration: 120,
                    image: "running-3.png",
                    description: "",
                    startSpeech: "Run In Place 2 minutes",
                    thirtySecondsLeftSpeech: "30 seconds left",
                    tenSecondsLeftSpeech: "",
                    fiveSecondsLeftSpeech: "",
                    endSpeech: "Exercise completed"),

//            (id: 4,
//                    name: "Surya Namaskar",
//                    duration: 120,
//                    image: "surya-namaskar-4.png",
//                    description: "A set of yoga asanas (postures) that provide a good cardiovascular workout. Literally translated to sun salutation, these postures are a good way to keep the body in shape and the mind calm and healthy.",
//                    startSpeech: "Surya Namaskar 1 minute",
//                    thirtySecondsLeftSpeech: "30 seconds left",
//                    tenSecondsLeftSpeech: "10 seconds left",
//                    fiveSecondsLeftSpeech: "5 seconds left",
//                    endSpeech: "Exercise completed")
            // Add Headstanding someday to show speech usage.
        ]

        exercises.forEach {
            if let image = UIImage(named: $0.image),
//           let docDir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            // TODO: `create: true` or `false`? Make it global? Appropriate?
               let docDir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {

                let imageURL = docDir.appendingPathComponent("\($0.name)-\($0.id)-0.png")
                let _ = saveImage(image: image, path: imageURL)

                state.exercises.append(
                        Exercise(id: $0.id,
                                name: $0.name,
                                duration: $0.duration,
                                speech: Exercise.Speech(
                                        start: $0.startSpeech,
                                        thirtySecondsLeft: $0.thirtySecondsLeftSpeech,
                                        tenSecondsLeft: $0.tenSecondsLeftSpeech,
                                        fiveSecondsLeft: $0.fiveSecondsLeftSpeech,
                                        end: $0.endSpeech),
                                description: $0.description)
                )
                state.enabledExercises.append(EnabledExercise(workoutId: nil, exerciseId: $0.id, name: $0.name))
            }
        }

        state.exercises.save()
        state.enabledExercises.saveAndArrangeWorkouts()

//        state.exercises.save()
        // EnabledExercise + Re-arrange

//        state.exercises.append(Exercise(id: 1, name: "Leg Raise", duration: 60, speech: Exercise.Speech(start: "start"), description: "hello"))

//        init(start: String = "", thirtySecondsLeft: String = "", tenSecondsLeft: String = "", fiveSecondsLeft: String = "", end: String = "") {
//        init(id: Int? = nil, name: String = "Exercise", duration: Int = 60, speech: Speech = Speech(), description: String = "") {


        let _ = state.settings.save()
    }
}

struct Formatter: Codable {
    // 120 -> 2:00
    func secondsToHuman(seconds: Int) -> String {
        return String(format: "%02i:%02i", seconds / 60, seconds % 60)
    }
}

let formatter = Formatter()

class Settings: Codable {
    var notificationInterval: Double
    var dateNotificationCreated: Date
    var notificationSwitchIsOn: Bool
    var workoutDuration: Double
    var autostart: Bool
    var notificationText: String
//    let timerOffAt: Date = Date() // Do I need it really?
    var workoutCompleteSpeech: String
    var notificationIntervalInSeconds: Double {
        return self.notificationInterval * 60
    }
    var workoutDurationInSeconds: Int {
        return Int(self.workoutDuration * 60)
    }

    init(notificationInterval: Double, workoutDuration: Double, notificationText: String, autostart: Bool, dateNotificationCreated: Date, notificationSwitchIsOn: Bool, workoutCompleteSpeech: String) {
        self.notificationInterval = notificationInterval
        self.workoutDuration = workoutDuration
        self.notificationText = notificationText
        self.autostart = autostart
        self.dateNotificationCreated = dateNotificationCreated
        self.notificationSwitchIsOn = notificationSwitchIsOn
        self.workoutCompleteSpeech = workoutCompleteSpeech
    }
}

class Coach {
    struct CurrentExercise {
        let exercise: Exercise

        var startSpoken: Bool = false
        var endSpoken: Bool = false
        var thirtySecondsLeftSpoken: Bool = false
        var tenSecondsLeftSpoken: Bool = false
        var fiveSecondsLeftSpoken: Bool = false

        init(exercise: Exercise) {
            self.exercise = exercise
        }
    }

    var coachViewDelegate: CoachViewController?
    var mainViewDelegate: ViewController?
    let speechSynthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    var exercises: [Exercise] { return workout.exercises }
    var currentExercise: CurrentExercise
    var currentExerciseIndex: Int { return workout.exercises.index(of: currentExercise.exercise)! }
    var currentExerciseDuration: Int { return currentExercise.exercise.duration }
//    var currentExerciseDuration: Int { return 3 }
    var secondsSinceExerciseStarted: Int {
        return Int(Date().timeIntervalSince(exerciseStarted!))
    }
    var workout: Workout
    var totalDuration: Int?
//    var durationLeft: Int?

    var timer: Timer? = nil {
        willSet {
            timer?.invalidate()
        }
    }

    var exerciseStarted: Date?

    func speaker(say speech: String) {
        let speech = AVSpeechUtterance(string: speech)
        DispatchQueue.main.async(execute: {
            self.speechSynthesizer.speak(speech)
        })
    }

    func stop() throws {
        // https://stackoverflow.com/questions/44633729/stop-a-dispatchqueue-that-is-running-on-the-main-thread
//        print("stopping workout")

        guard let timer = timer else {
            print("Workout: timer is not set")
            throw WorkoutErrors.timerNotSet
        }

        timer.invalidate()
    }

    init() {
        self.workout = state.workouts.returnAndAssignNext()
        currentExercise = CurrentExercise(exercise: workout.exercises.first!)

        notifications.center.removeAllDeliveredNotifications()

        totalDuration = exercises.duration

        speaker(say: currentExercise.exercise.speech.start)
        exerciseStarted = Date()
        self.startTimer()
    }

    @objc func updateTimer() {
        let secondsLeft = (self.currentExerciseDuration - self.secondsSinceExerciseStarted) % 60
        let minutesLeft = ((self.currentExerciseDuration - self.secondsSinceExerciseStarted) / 60)

        // It runs on the main queue by default, doesn't it?
        DispatchQueue.main.async {
            if secondsLeft < 0 {
                self.coachViewDelegate?.updateLabel(with: "0:00")
            } else {
                self.coachViewDelegate?.updateLabel(with: String(format: "%02i:%02i", Int(minutesLeft), Int(secondsLeft)))
            }
        }

        if minutesLeft == 0 {
            DispatchQueue.global(qos: .userInitiated).async {
                switch secondsLeft {
                case 30:
                    if self.currentExercise.thirtySecondsLeftSpoken {
                        break
                    } else {
                        self.speaker(say: self.currentExercise.exercise.speech.thirtySecondsLeft)
                        self.currentExercise.thirtySecondsLeftSpoken = true
                    }
                case 10:
                    if self.currentExercise.tenSecondsLeftSpoken {
                        break
                    } else {
                        self.speaker(say: self.currentExercise.exercise.speech.tenSecondsLeft)
                        self.currentExercise.tenSecondsLeftSpoken = true
                    }
                case 5:
                    if self.currentExercise.fiveSecondsLeftSpoken {
                        break
                    } else {
                        self.speaker(say: self.currentExercise.exercise.speech.fiveSecondsLeft)
                        self.currentExercise.fiveSecondsLeftSpoken = true
                    }
                case 0:
                    if self.currentExercise.endSpoken {
                        break
                    } else {
                        self.speaker(say: self.currentExercise.exercise.speech.end)
                        self.currentExercise.endSpoken = true
                    }

                    if self.secondsSinceExerciseStarted >= self.currentExerciseDuration && self.currentExercise.exercise == self.workout.exercises.last {
                        // TODO: Spoken?
                        self.speaker(say: state.settings[0].workoutCompleteSpeech)
                    }
                default:
                    break
                }
            }
        }

        if self.secondsSinceExerciseStarted > self.currentExerciseDuration {
            if self.currentExercise.exercise == self.workout.exercises.last {
                self.timer!.invalidate()
                self.coachViewDelegate?.performSegueToReturnBack()
            } else {
                self.currentExercise = CurrentExercise(exercise: self.workout.exercises[self.currentExerciseIndex + 1])
                self.coachViewDelegate!.exerciseChanged()
                self.exerciseStarted = Date()

                self.timer!.invalidate()
                self.startTimer()
                self.speaker(say: self.currentExercise.exercise.speech.start)
            }
        }
    }

    func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }
}

class Exercise: Codable, Equatable, HasId {
    let id: Int?
    var name: String
    var duration: Int
    var speech: Speech
    var description: String

    init(id: Int? = nil, name: String = "Exercise", duration: Int = 60, speech: Speech = Speech(), description: String = "") {
        if id != nil {
            self.id = id
        } else {
            var suggestedId = state.exercises.count + 1
            while state.exercises.findBy(id: suggestedId) != nil {
                suggestedId += 1
            }
            print("suggestedId: \(suggestedId)")
            self.id = suggestedId
        }

        self.name = name
        self.duration = duration
        self.speech = speech
        self.description = description
    }

    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id
    }

    struct Speech: Codable {
        var start: String
        var thirtySecondsLeft: String
        var tenSecondsLeft: String
        var fiveSecondsLeft: String
        var end: String

        init(start: String = "", thirtySecondsLeft: String = "", tenSecondsLeft: String = "", fiveSecondsLeft: String = "", end: String = "") {
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

protocol HasId {
    var id: Int? { get }
}

extension Array where Element: HasId {
    func findBy(id: Int) -> Element? {
        let found = self.filter { $0.id == id }
        if found.count > 0 {
            return found[0]
        } else {
            return nil
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

    func save() {
        state.exercises = self
        let _ = manager.save(data: self)
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

    func saveAndArrangeWorkouts() {
        state.enabledExercises = self
        state.workouts = []
        state.workouts.arrange(exercises: (exercisesUsed: [], exercisesLeft: self))
        let _ = manager.save(data: self)
    }

//    func findByExerciseId(id: Int) -> EnabledExercise {
//        return self.filter { $0.exerciseId == id }[0]
//    }

    func delete(exercise: Exercise) {
        state.enabledExercises = state.enabledExercises.filter { $0.exerciseId != exercise.id}
        state.enabledExercises.saveAndArrangeWorkouts()
    }
}

typealias SortedExercisesTuple = (exercisesUsed: [EnabledExercise], exercisesLeft: [EnabledExercise])

extension Array where Element: Workout {
    private var manager: DataManager<Workout> { return DataManager() }

    var next: Workout? {
        var workout: Workout? = nil
        if (self.filter { $0.next == true }.count) > 0 {
            workout = self.filter { $0.next == true }[0]
        }
        return workout
    }

    func returnAndAssignNext() -> Workout {
        if (self.filter { $0.next == true }.count) > 0 {
            let workout = self.filter { $0.next == true }[0]
            self.assignNext(workout: workout)
            return workout
        } else {
            let workout = self.first!
            self.assignNext(workout: workout)
            return workout
        }
    }

    var saved: [Workout] {
        state.workouts = manager.saved()
        return state.workouts
    }

    func assignNext(workout: Workout) -> () {
        let currentWorkoutIndex: Int = state.workouts.index(of: workout)!
        if state.workouts.count > currentWorkoutIndex + 1 {
            state.workouts[currentWorkoutIndex + 1].next = true
        } else {
            if let firstWorkout = state.workouts.first {
                firstWorkout.next = true
            }
        }
        workout.next = false
        let _ = state.workouts.save()
    }

    func save() -> Bool {
        state.workouts = self
        return manager.save(data: self)
    }

    func refresh() {
        state.workouts = []

        if state.enabledExercises.count > 0 {
            self.arrange(exercises: (exercisesUsed: [], exercisesLeft: state.enabledExercises))
        } else {
            let _ = state.workouts.save()
        }
    }

    private func arrange(exercises: SortedExercisesTuple) {
        // Might recurse if duration is too small.
        var duration = state.settings[0].workoutDurationInSeconds

        // Skip exercises with long (> settings) duration.

        func sortExercises(exercises: SortedExercisesTuple) -> SortedExercisesTuple {
            var sortedExercises: SortedExercisesTuple = (exercisesUsed: [], exercisesLeft: [])
            exercises.exercisesLeft.forEach({ exercise in
                guard exercise.duration <= state.settings[0].workoutDurationInSeconds else {
                    print("Exercise is too long")
                    return
                }
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
        state.workouts.append(Workout(next: false, enabledExercises: sortedExercises.exercisesUsed))
        if sortedExercises.exercisesLeft.count > 0 {
            state.workouts.arrange(exercises: (exercisesUsed: [], exercisesLeft: sortedExercises.exercisesLeft))
        } else {
            guard state.workouts.count > 0 && state.workouts.first!.enabledExercises.count > 0 else {
                state.workouts = []
                return
            }

            if let workout = state.workouts.first {
                workout.next = true
            }
            let _ = state.workouts.save()
        }
    }
}

class EnabledExercise: Codable, Equatable, HasId {
    let id: Int?
    let exerciseId: Int
    var workoutId: Int?
    let name: String
    var duration: Int {
//        return state.exercises.filter { $0.id == exerciseId }[0].duration
        let filteredExercises = state.exercises.filter { $0.id == exerciseId }
        if filteredExercises.count > 0 {
            return filteredExercises[0].duration
        } else {
            print("Exercise not found")
            return 0
        }
    }

    init(workoutId: Int?, exerciseId: Int, name: String) {
        self.exerciseId = exerciseId
        if workoutId != nil {
            self.workoutId = workoutId
        }
        self.name = name
        var suggestedId = state.enabledExercises.count + 1
        while state.enabledExercises.findBy(id: suggestedId) != nil {
            suggestedId += 1
        }
        self.id = suggestedId
    }

    static func == (lhs: EnabledExercise, rhs: EnabledExercise) -> Bool {
        return lhs.id == rhs.id
    }
}

class Workout: Codable, Equatable, HasId {
    let id: Int?
    var next: Bool = false
    var enabledExercises: [EnabledExercise]
    var exercises: [Exercise] {
        return self.enabledExercises.flatMap { enabledExercise in
            return state.exercises.filter { exercise in
                return exercise.id == enabledExercise.exerciseId
            }
        }
    }
    let reminder: Int = testMode ? 3 : 30 // delete

    var duration: Int {
        return self.enabledExercises.reduce(0, { duration, enabledExercise in
            let exercisesFiltered: [Exercise] = exercises.filter { $0.id == enabledExercise.exerciseId }
            if exercisesFiltered.count > 0 {
                return exercisesFiltered[0].duration + duration
            } else {
                return duration
            }
        })
    }

    var description: String {
        return "Workout: #\(self.id ?? 0)" +
                ", next?: \(self.next)" +
                ", exercises.count: \(self.exercises.count)" +
                ", enabledExercises.count: \(self.enabledExercises.count) \n" +
                "first exercise name: \(self.exercises.first?.name ?? "unknown") id: \(self.exercises.first?.id ?? 0) \n" +
                "first enabled exercise name: \(self.enabledExercises.first?.name ?? "unknown") exerciseId: \(self.enabledExercises.first?.exerciseId ?? 0)"
    }

    static func == (lhs: Workout, rhs: Workout) -> Bool {
        return lhs.id == rhs.id
    }

    init(next: Bool, enabledExercises: [EnabledExercise]) {
        // https://stackoverflow.com/questions/32332985/how-to-use-audio-in-ios-application-with-swift-2
        self.next = next
        self.enabledExercises = enabledExercises
        var suggestedId = state.workouts.count + 1
        while state.workouts.findBy(id: suggestedId) != nil {
            suggestedId += 1
        }
        self.id = suggestedId

        self.enabledExercises.forEach { exercise in
            exercise.workoutId = self.id
        }

    }
}

