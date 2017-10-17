//
//  WorkoutsTableViewController.swift
//  Sedentary
//
//  Created by vt on 10/6/17.
//  Copyright © 2017 Vasiliy Tokarev. All rights reserved.
//

import UIKit

class WorkoutsExercisesTableViewController: UITableViewController {
    var selectedCell: Navigation.WorkoutsExercisesTableViewController.Cell?

    let workoutsSection: Int = Navigation.WorkoutsExercisesTableViewController.Section.workouts.number
    let workoutsSectionName: String = Navigation.WorkoutsExercisesTableViewController.Section.workouts.name
    let exercisesSection: Int = Navigation.WorkoutsExercisesTableViewController.Section.exercises.number
    let exercisesSectionName: String = Navigation.WorkoutsExercisesTableViewController.Section.exercises.name

    let worksoutsExercisesToExercisesSegue: String = Navigation.Segue.workoutsExercisesToExercises.identifier

    let workoutsExercisesCell: String = Navigation.WorkoutsExercisesTableViewController.Cell.Identifier.workoutsExercisesCell.identifier

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
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int = 0
        if section == workoutsSection {
            numberOfRows = enabledExercises.count
        } else if section == exercisesSection {
            if exercises.count > 0 {
                numberOfRows = exercises.count + 1
            } else {
                numberOfRows = 1
            }
        }
        return numberOfRows
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == worksoutsExercisesToExercisesSegue {
            let workoutsTableViewController = segue.destination as! ExercisesTableViewController
            workoutsTableViewController.selectedCell = selectedCell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == exercisesSection {
            selectedCell = Navigation.WorkoutsExercisesTableViewController.Cell.newExercise
            performSegue(withIdentifier: worksoutsExercisesToExercisesSegue, sender: nil)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: workoutsExercisesCell, for: indexPath) as! WorkoutsExercisesTableViewCell
        if indexPath.section == workoutsSection {
            if enabledExercises.count > 0 {
                cell.update(with: enabledExercises[indexPath.row])
                // Update label with workout.each?.exercises.first.id == enabledExercise  .timeAt
                // What if there are two of them?
            }
        } else {
            if exercises.count > 0 && indexPath.row <= exercises.count - 1 {
                cell.update(with: exercises[indexPath.row])
            }

            if exercises.count == 0 {
                cell.update(with: "New Exercise")
            }

            if exercises.count > 0 && indexPath.row == exercises.count {
                cell.update(with: "New Exercise")
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == workoutsSection {
            return workoutsSectionName
        } else {
            return exercisesSectionName
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        // TODO: Refactor this.
        if (indexPath.section == exercisesSection && exercises.count == 0) || (indexPath.section == exercisesSection && exercises.count > 0 && indexPath.row == exercises.count) {
            return false
        } else {
            return true
        }
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == workoutsSection {
                enabledExercises.remove(at: indexPath.row)
                if enabledExercises.save() {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            } else {
                exercises.remove(at: indexPath.row)
                if exercises.save() {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
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
                let exercise = exercises[fromIndexPath.row]
                enabledExercises.insert(EnabledExercise(exerciseID: exercise.id!, name: exercise.name!), at: to.row)
                let _ = enabledExercises.save()
//                workouts.arrange()
//                let _ = workouts.save()
            case fromExercisesToExercises:
                let movedExercise = exercises[fromIndexPath.row]
                exercises.remove(at: fromIndexPath.row)
                exercises.insert(movedExercise, at: to.row)
                exercises.save()
            case fromWorkoutsToWorkouts:
                let movedExercise = enabledExercises[fromIndexPath.row]
                enabledExercises.remove(at: fromIndexPath.row)
                enabledExercises.insert(movedExercise, at: to.row)
                enabledExercises.save()

                workouts = []
                workouts.save()
                print("saved")
                workouts.arrange(exercises: (exercisesUsed: [], exercisesLeft: enabledExercises))

                print("workouts count: \(workouts.count)")
                print("workouts exercises count: \(workouts[0].enabledExercises!.count)")
                print("workouts exercises duration: \(workouts[0].duration())")
            case fromWorkoutsToExercises:
                print("fromWorkoutsToExercises")
                // Remove workouts[fromIndexPath.row]
            default:
                print("default")
        }

        tableView.reloadData() // Remove it after arrange() is implemented.
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

    @IBAction func unwindToWorkoutsExercises(segue: UIStoryboardSegue) {
        print("unwinding")
    }
}
