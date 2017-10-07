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

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        return 2 // + 1
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
        
        if indexPath.section == 0 {
            // create a segue to New workout/exercise
            // add UILabel with 
            // attach segue to UILabel
            if indexPath.row == 1 {
                cell.update(with: "Add workout")
            } else {
                // Use data source to count numberOfRows
                // Distringuish this row.
                cell.update(with: Workout(ids: [1], name: "Test workout"))
            }
        } else {
            if indexPath.row == 1 {
                cell.update(with: "Add exercise")
            } else {
                cell.update(with: Workout(ids: [1], name: "Exercise 1"))
            }
        }
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Workouts"
        } else {
            return "Exercises"
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
