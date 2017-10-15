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
            numberOfRows = workoutsManager.workouts.count
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
            if workouts.count > 0 {
                cell.update(with: workoutsManager.workouts[indexPath.row])
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
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            exercises.remove(at: indexPath.row)
            let _ = exercises.save()
//            if exercises.save {
//                tableView.deleteRows(at: [indexPath], with: .fade)
//            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        // Set label with next time.
//        let ids = exercises.filter { $0.id == exercises[fromIndexPath.row].id }.map { $0.id }

        let exercise = exercises.filter { $0.id == exercises[fromIndexPath.row].id }[0]
        if workouts.count == 0 {
            workouts.insert(Workout(exercises: exercises, name: exercise.name!), at: to.row)
            let _ = workouts.save()
        } else {
        }
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
}
