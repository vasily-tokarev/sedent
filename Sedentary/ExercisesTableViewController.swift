//
//  ExercisesTableViewController.swift
//  Sedentary
//
//  Created by vt on 10/6/17.
//  Copyright © 2017 Vasiliy Tokarev. All rights reserved.
//

import UIKit

class ExercisesTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var selectedCell: Navigation.WorkoutsExercisesTableViewController.Cell?
    
    let imageSection: Int = Navigation.ExercisesTableViewController.Section.image.number

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

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let exerciseId: Int
        if exercises.count > 0 {
            exerciseId = exercises.count
        } else {
            exerciseId = 0
        }
        exercises.append(Exercise(id: exerciseId, name: nameTextField.text!, speech: Exercise.Speech(start: "hello")))
        if exercises.save() {
            print("going back from ExerciseTableViewController")
//            dismiss(animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100 // Something close to your average cell height
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.'
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 6
    }
/**/
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

        // TODO: Enum! I don't even know what it is.
        if section == 3 {
            return 3
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == imageSection {
            let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
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
}
