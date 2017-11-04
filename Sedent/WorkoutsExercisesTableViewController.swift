//
//  WorkoutsTableViewController.swift
//  Sedent
//
//  Created by vt on 10/6/17.
//  Copyright © 2017 Vasiliy Tokarev. All rights reserved.
//

import UIKit

class WorkoutsExercisesTableViewController: UITableViewController {
    var selectedExerciseIndex: Int?

    let workoutsSection: Int = Navigation.WorkoutsExercisesTableViewController.Section.workouts.number
    let workoutsSectionName: String = Navigation.WorkoutsExercisesTableViewController.Section.workouts.name
    let exercisesSection: Int = Navigation.WorkoutsExercisesTableViewController.Section.exercises.number
    let exercisesSectionName: String = Navigation.WorkoutsExercisesTableViewController.Section.exercises.name
    let newExerciseSection: Int = Navigation.WorkoutsExercisesTableViewController.Section.newExercise.number
    let newExerciseSectionName: String = Navigation.WorkoutsExercisesTableViewController.Section.newExercise.name

    let worksoutsExercisesToExercisesSegue: String = Navigation.Segue.workoutsExercisesToExercises.identifier

    let workoutsExercisesCell: String = Navigation.WorkoutsExercisesTableViewController.Cell.Identifier.workoutsExercisesCell.identifier

    @IBAction func unwindToWorkoutsExercises(segue: UIStoryboardSegue) {
//        print("unwinding to")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = editButtonItem

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int = 0
        switch section {
        case workoutsSection:
            numberOfRows = state.enabledExercises.count
        case exercisesSection:
            numberOfRows = state.exercises.count
        case newExerciseSection:
            numberOfRows = 1
        default:
            break
        }
        return numberOfRows
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == worksoutsExercisesToExercisesSegue {
            let workoutsTableViewController = segue.destination as! ExercisesTableViewController
            workoutsTableViewController.selectedExerciseIndex = selectedExerciseIndex
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case exercisesSection:
            selectedExerciseIndex = indexPath.row
            performSegue(withIdentifier: worksoutsExercisesToExercisesSegue, sender: nil)
        case newExerciseSection:
            selectedExerciseIndex = nil
            performSegue(withIdentifier: worksoutsExercisesToExercisesSegue, sender: nil)
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard indexPath.section != workoutsSection else {
            return nil
        }
        return indexPath
//        return super.tableView(tableView, willSelectRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: workoutsExercisesCell, for: indexPath) as! WorkoutsExercisesTableViewCell

        switch indexPath.section {
        case workoutsSection:
            cell.update(with: state.enabledExercises[indexPath.row])
        case exercisesSection:
            cell.update(with: state.exercises[indexPath.row])
        case newExerciseSection:
            cell.update(with: "New Exercise")
        default:
            break
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case workoutsSection:
            return workoutsSectionName
        case exercisesSection:
            return exercisesSectionName
        case newExerciseSection:
            return ""
        default:
            return "Unknown Section"
        }
    }


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch indexPath.section {
            case workoutsSection:
                state.enabledExercises.remove(at: indexPath.row)
            case exercisesSection:
                state.enabledExercises = state.enabledExercises.filter { $0.exerciseId != state.exercises[indexPath.row].id}
                let exercise = state.exercises[indexPath.row]

//                let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//                let imageURL = docDir.appendingPathComponent("\(exercise.name)-\(exercise.id)-0.png")

                if let exerciseId = exercise.id,
                   let docDir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
                    let imageURL = docDir.appendingPathComponent("\(exercise.name)-\(exerciseId)-0.png")
                    do {
                        try FileManager.default.removeItem(at: imageURL)
                    } catch let error as NSError {
                        print("Error: \(error.domain)")
                    }
                }

                state.exercises.remove(at: indexPath.row)
                state.exercises.save()
            default:
                break
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        state.enabledExercises.saveAndArrangeWorkouts()
        tableView.reloadData()
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
//        let ids = exercises.filter { $0.id == exercises[fromIndexPath.row].id }.map { $0.id }
        let fromExercisesToWorkouts = fromIndexPath.section == exercisesSection && to.section == workoutsSection
        let fromExercisesToExercises = fromIndexPath.section == exercisesSection && to.section == exercisesSection
        let fromWorkoutsToExercises = fromIndexPath.section == workoutsSection && to.section == exercisesSection
        let fromWorkoutsToWorkouts = fromIndexPath.section == workoutsSection && to.section == workoutsSection

        switch true {
        case fromExercisesToWorkouts:
            let exercise = state.exercises[fromIndexPath.row]
            if exercise.duration <= Int(state.settings[0].workoutDurationInSeconds) {
                state.enabledExercises.insert(EnabledExercise(workoutId: nil, exerciseId: exercise.id!, name: exercise.name), at: to.row)
                let _ = state.enabledExercises.saveAndArrangeWorkouts()
            }
        case fromExercisesToExercises:
            print("to.row: \(to.row)")
            print("state.exercises.count: \(state.exercises.count)")
            guard to.row < state.exercises.count else {
                print("new exercise row")
                return
            }
            let movedExercise = state.exercises[fromIndexPath.row]
            state.exercises.remove(at: fromIndexPath.row)
            state.exercises.insert(movedExercise, at: to.row)
            let _ = state.exercises.save()
        case fromWorkoutsToWorkouts:
            let movedExercise = state.enabledExercises[fromIndexPath.row]
            state.enabledExercises.remove(at: fromIndexPath.row)
            state.enabledExercises.insert(movedExercise, at: to.row)
            let _ = state.enabledExercises.saveAndArrangeWorkouts()
        case fromWorkoutsToExercises:
            print("fromWorkoutsToExercises")
                // Remove workouts[fromIndexPath.row]
        default:
            print("default")
        }

        tableView.reloadData() // TODO: Is this required?
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        guard indexPath.section != newExerciseSection else {
            return false
        }
        return true
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        guard indexPath.section != newExerciseSection else {
            return false
        }
        return true
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return super.tableView(tableView, heightForRowAt: indexPath)
        return 50
    }
}
