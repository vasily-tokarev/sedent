//
//  ExercisesTableViewController.swift
//  Sedentary
//
//  Created by vt on 10/6/17.
//  Copyright © 2017 Vasiliy Tokarev. All rights reserved.
//

import UIKit


//let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//let archiveURL = documentsDirectory.appendingPathComponent("user_settings").appendingPathExtension("plist")
//let propertyListEncoder = PropertyListEncoder()
//let encodedUserSettings = try? propertyListEncoder.encode(userSettings)
//
//try? encodedUserSettings?.write(to: archiveURL, options: .noFileProtection)
//
//// reading
//let propertyListDecoder = PropertyListDecoder()
//if let retrievedUserSettingsData = try? Data(contentsOf: archiveURL),
//    let decodedUserSettings = try?
//        propertyListDecoder.decode(UserSettings.self, from: retrievedUserSettingsData) {
//    print(decodedUserSettings)
//}

//struct Exercise {
//    let id: Int
//    var name: String
//    var duration: Int
//    var image: UIImage
//    struct Speech {
//        var start: String
//        var speechThirty: String
//        var speechTen: String
//        var speechFive: String
//        var speechLast: String
//    }
//    var description: String
//}

class ExercisesTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var selectedCell: CellType?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationStepper: UIStepper!
    
    @IBOutlet weak var startSpeech: UITextField!
    @IBOutlet weak var thirtySecondsLeftSpeech: UITextField!
    @IBOutlet weak var tenSecondsLeftSpeech: UITextField!
    @IBOutlet weak var fiveSecondsLeftSpeech: UITextField!
    @IBOutlet weak var endSpeech: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    enum Section: Int {
        case image = 2
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let exerciseId: Int
        if exercises.count > 0 {
            exerciseId = exercises.count
        } else {
            exerciseId = 0
        }
        exercises.append(Exercise(id: exerciseId, name: nameTextField.text))

        print(DataManager().saveExercises(exercises: exercises))
        print(DataManager().exercises())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100 // Something close to your average cell height

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
        return 6
    }
/**/
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 3 {
            return 3
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Image view.
        if indexPath.section == Section.image.rawValue {
            let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                print("source available")
                let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {
                    action in
                        imagePicker.sourceType = .camera
                        self.present(imagePicker, animated: true, completion: nil)
                })
                alertController.addAction(cameraAction)
            }
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: {
                    action in
                    imagePicker.sourceType = .photoLibrary
                    self.present(imagePicker, animated: true, completion: nil)
                })
                alertController.addAction(photoLibraryAction)
            }
            
//            alertController.popoverPresentationController?.sourceView = sender
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = selectedImage
            dismiss(animated: true, completion: nil)
        }
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
