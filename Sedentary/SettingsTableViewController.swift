//
//  SettingsTableViewController.swift
//  Sedentary
//
//  Created by vt on 10/5/17.
//  Copyright © 2017 Vasiliy Tokarev. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    var settings: Settings = state.settings[0]

    @IBOutlet weak var notificationIntervalStepper: UIStepper!
    @IBOutlet weak var notificationIntervalStepperLabel: UILabel!
    
    @IBOutlet weak var workoutDurationStepper: UIStepper!
    @IBOutlet weak var workoutDurationStepperLabel: UILabel!
    
    @IBOutlet weak var notificationTextField: UITextField!
    @IBOutlet weak var autostartSwitch: UISwitch!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check segue identifier
        // https://medium.com/yay-its-erica/how-to-pass-data-in-an-unwind-segue-swift-3-1c3fa095cde1
        state.settings[0] = settings
        let _ = state.settings.save()
        state.workouts.refresh()
    }
    
    @IBAction func notificationIntervalStepperValueChanged(_ sender: UIStepper) {
        settings.notificationInterval = notificationIntervalStepper.value
        let value = String(format: "%.0f", notificationIntervalStepper.value)
        notificationIntervalStepperLabel.text = "\(value) minutes"
    }
    
    @IBAction func workoutDurationStepperValueChanged(_ sender: UIStepper) {
        settings.workoutDuration = workoutDurationStepper.value
        let value = String(format: "%.0f", workoutDurationStepper.value)
        var text: String
        if workoutDurationStepper.value > 1.0 {
            text = "minutes"
        } else {
            text = "minute"
        }
        workoutDurationStepperLabel.text = "\(value) \(text)"
    }
    
    @IBAction func autostartSwitchValueChanged(_ sender: UISwitch) {
    }
    

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        let nav = self.navigationController?.navigationBar
////        nav?.barStyle = UIBarStyle.Black
//        nav?.tintColor = UIColor.white
//        nav?.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        notificationIntervalStepper.value = state.settings[0].notificationInterval

        let notificationIntervalString = String(format: "%.0f", state.settings[0].notificationInterval)
        notificationIntervalStepperLabel.text = "\(notificationIntervalString) minutes"
        print(notificationIntervalString)

        workoutDurationStepper.value = state.settings[0].workoutDuration
        let workoutDurationString = String(format: "%.0f", workoutDurationStepper.value)
        var text: String
        if workoutDurationStepper.value > 1.0 {
            text = "minutes"
        } else {
            text = "minute"
        }
        workoutDurationStepperLabel.text = "\(workoutDurationString) \(text)"

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
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
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
