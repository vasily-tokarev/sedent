//
//  TimePickerTableViewController.swift
//  Sedentary
//
//  Created by vt on 10/5/17.
//  Copyright © 2017 Vasiliy Tokarev. All rights reserved.
//

// MAYBE STEPPER???? 30 seconds step.
// Random exercises which are selected in Manage section?
// Time to turn off notifications.

// Show total time in manager exercises.
// Reorder them (show when each exercise will be performed?)

// NEXT EXERCISE AT 12:30 on the main screen.

import UIKit

struct UserSettings: Codable {
    let notificationInterval: Double
}

class TimePickerTableViewController: UITableViewController {
    @IBOutlet weak var notificationIntervalStepper: UIStepper!
    @IBOutlet weak var notificationIntervalStepperLabel: UILabel!
    
    @IBOutlet weak var workoutDurationStepper: UIStepper!
    @IBOutlet weak var workoutDurationStepperLabel: UILabel!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check segue identifier
        // https://medium.com/yay-its-erica/how-to-pass-data-in-an-unwind-segue-swift-3-1c3fa095cde1
        print("done button tapped")
        
        let userSettings = UserSettings(notificationInterval: notificationIntervalStepper.value)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("user_settings").appendingPathExtension("plist")
        let propertyListEncoder = PropertyListEncoder()
        let encodedUserSettings = try? propertyListEncoder.encode(userSettings)
        
        try? encodedUserSettings?.write(to: archiveURL, options: .noFileProtection)
        
        // reading
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedUserSettingsData = try? Data(contentsOf: archiveURL),
            let decodedUserSettings = try?
                propertyListDecoder.decode(UserSettings.self, from: retrievedUserSettingsData) {
            print(decodedUserSettings)
        }
    }
    
    @IBAction func notificationIntervalStepperValueChanged(_ sender: UIStepper) {
        let value = String(format: "%.0f", notificationIntervalStepper.value)
        print(value)
        print(String(format: "%.0f", "\(value)m"))
        notificationIntervalStepperLabel.text = "\(value)m"
    }
    
    @IBAction func workoutDurationStepperValueChanged(_ sender: UIStepper) {
        let value = String(format: "%.0f", workoutDurationStepper.value)
        workoutDurationStepperLabel.text = "\(value)m"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("timePickerView did load")
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("user_settings").appendingPathExtension("plist")
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedUserSettingsData = try? Data(contentsOf: archiveURL),
            let decodedUserSettings = try?
                propertyListDecoder.decode(UserSettings.self, from: retrievedUserSettingsData) {
            print(decodedUserSettings)
            notificationIntervalStepper.value = decodedUserSettings.notificationInterval
            let value = String(format: "%.0f", decodedUserSettings.notificationInterval)
            notificationIntervalStepperLabel.text = "\(value)m"
        }
        
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
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
