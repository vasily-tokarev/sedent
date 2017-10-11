//
//  WorkoutsTableViewController.swift
//  Sedentary
//
//  Created by vt on 10/6/17.
//  Copyright © 2017 Vasiliy Tokarev. All rights reserved.
//

import UIKit

class WorkoutsExercisesTableViewController: UITableViewController {
    var selectedCell: CellType?
    
    enum Section: Int {
        case workouts = 0
        case exercises = 1
    }
    
    let workoutsSection: Int = Section.workouts.rawValue
    let exercisesSection: Int = Section.exercises.rawValue

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        exercises = DataManager().exercises()
        print("exercises.count (viewWillAppear): \(exercises.count)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem
//        navigationItem.backBarButtonItem
        
        // https://www.ralfebert.de/tutorials/ios-swift-uitableviewcontroller/reorderable-cells/
//        self.tableView.isEditing = true

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var numberOfRows: Int = 0
        if section == workoutsSection {
            numberOfRows = workouts.count
//            if workouts.count > 0 {
//                numberOfRows = workouts.count + 1
//            } else {
//                numberOfRows = 1
//            }
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
        if segue.identifier == Segue.worksoutsExercisesToExercises.rawValue {
            let workoutsTableViewController = segue.destination as! ExercisesTableViewController
            workoutsTableViewController.selectedCell = selectedCell
        } else if segue.identifier == Segue.worksoutsExercisesToExercises.rawValue {
            let workoutsTableViewController = segue.destination as! WorkoutsTableViewController
            workoutsTableViewController.selectedCell = selectedCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { // and indexPath.row[workouts.last - 1]
            selectedCell = CellType.newWorkout
            performSegue(withIdentifier: Segue.worksoutsExercisesToWorkouts.rawValue, sender: nil)
        } else if indexPath.section == 1 {
            selectedCell = CellType.newExercise
            performSegue(withIdentifier: Segue.worksoutsExercisesToExercises.rawValue, sender: nil)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.workoutsExercisesCell.rawValue, for: indexPath) as! WorkoutsExercisesTableViewCell
        print("exercises.count (cellForRowAt): \(exercises.count)")
        if indexPath.section == workoutsSection {
            if workouts.count > 0 {
                cell.update(with: workouts[indexPath.row])
                cell.showsReorderControl = true
            }
            
//            if workouts.count == 0 {
//                cell.update(with: "New Workout")
//                cell.showsReorderControl = false
//            }
            
//            if workouts.count > 0 && indexPath.row == workouts.count + 1 {
//                cell.update(with: "New Workout")
//                cell.showsReorderControl = false
//            }

        } else {
            if exercises.count > 0 && indexPath.row <= exercises.count - 1 {
                print(indexPath.row)
                cell.update(with: exercises[indexPath.row])
                cell.showsReorderControl = true
            }
            
            if exercises.count == 0 {
                cell.update(with: "New Exercise")
                cell.showsReorderControl = false
            }
            
            if exercises.count > 0 && indexPath.row == exercises.count + 1 {
                cell.update(with: "New Exercise")
                cell.showsReorderControl = false
            }
        }
        

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == workoutsSection {
            return "Workouts"
        } else {
            return "Exercises"
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print("hitting delete")
        if editingStyle == .delete {
            // Delete the row from the data source
            print("exercises before (delete): \(exercises.count)")
            exercises.remove(at: indexPath.row)
            if DataManager().saveExercises(exercises: exercises) {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            print("exercises after (delete): \(exercises.count)")
//            DataManager
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
            workouts.insert(Workout(ids: [exercise.id], name: exercise.name!), at: to.row)
            print("workouts moveRowAt: \(workouts)")
        } else {
            print("workouts == 0 moveRowAt")
        }
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
