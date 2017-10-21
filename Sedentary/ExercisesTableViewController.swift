//
//  ExercisesTableViewController.swift
//  Sedentary
//
//  Created by vt on 10/6/17.
//  Copyright © 2017 Vasiliy Tokarev. All rights reserved.
//

import UIKit

class ExercisesTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    var selectedExerciseIndex: Int?
    var currentExercise: Exercise?

    let imageSection: Int = Navigation.ExercisesTableViewController.Section.image.number

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationStepper: UIStepper!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var startSpeechTextField: UITextField!
    @IBOutlet weak var thirtySecondsLeftSpeechTextField: UITextField!
    @IBOutlet weak var tenSecondsLeftSpeechTextField: UITextField!
    @IBOutlet weak var fiveSecondsLeftSpeechTextField: UITextField!
    @IBOutlet weak var endSpeechTextField: UITextField!
    // TODO: Hide keyboard. Return is not going to work.
    @IBOutlet weak var descriptionTextView: UITextView!

    @IBOutlet weak var saveButton: UIButton!

    @IBAction func durationStepperValueChanged(_ sender: UIStepper) {
        // TODO: Hide thirtySecondsSpeech
        let seconds = Int(durationStepper.value)
        let (h, m, s) = secondsToHoursMinutesSeconds(seconds: seconds)
        durationLabel.text = String(format: "%02i:%02i", m, s)
        if durationStepper.value < 60.0 {
            thirtySecondsLeftSpeechTextField.isEnabled = false
        } else {
            thirtySecondsLeftSpeechTextField.isEnabled = true
        }
    }

    func secondsToHoursMinutesSeconds (seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        func saveImage(image: UIImage, path: URL ) {
            let pngImageData = UIImagePNGRepresentation(image)
            //let jpgImageData = UIImageJPEGRepresentation(image, 1.0)   // if you want to save as JPEG
//            let result = pngImageData!.writeToFile(path, atomically: true)
            try? pngImageData!.write(to: path)
        }

        let exercise = Exercise (
                id: currentExercise?.id,
                name: nameTextField.text!,
                duration: Int(durationStepper.value),
                speech: Exercise.Speech(start: startSpeechTextField.text,
                        thirtySecondsLeft: thirtySecondsLeftSpeechTextField.text,
                        tenSecondsLeft: tenSecondsLeftSpeechTextField.text,
                        fiveSecondsLeft: fiveSecondsLeftSpeechTextField.text,
                        end: endSpeechTextField.text
                )
        )

        if let _ = currentExercise {
            exercisesGlobal[selectedExerciseIndex!] = exercise
        } else {
            exercisesGlobal.append(exercise)
        }

        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let imageURL = docDir.appendingPathComponent("\(exercise.name)-\(exercise.id)-0.png")

        if let image = imageView.image {
            let _ = saveImage(image: image, path: imageURL)
        }

        if exercisesGlobal.save() {
            print("going back from ExerciseTableViewController") // This will not execute, will it?
        }
        print(exercisesGlobal.last)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func formatDuration(value: Double) {
        let seconds = Int(value)
        let (h, m, s) = secondsToHoursMinutesSeconds(seconds: seconds)
        durationLabel.text = String(format: "%02i:%02i", m, s)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        formatDuration(value: durationStepper.value)
        if selectedExerciseIndex != exercisesGlobal.count {
            currentExercise = exercisesGlobal[selectedExerciseIndex!]
            if let exercise = currentExercise {
                let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let imageURL = docDir.appendingPathComponent("\(exercise.name)-\(exercise.id)-0.png")
                if let data = try? Data(contentsOf: imageURL) {
                    imageView.image = UIImage(data: data)
                }

                nameTextField.text! = exercise.name!
                durationStepper.value = Double(exercise.duration)
//                durationLabel.text = String(exercise.duration)
                formatDuration(value: Double(exercise.duration))
                startSpeechTextField.text = exercise.speech!.start
                thirtySecondsLeftSpeechTextField.text = exercise.speech?.thirtySecondsLeft
                tenSecondsLeftSpeechTextField.text = exercise.speech?.tenSecondsLeft
                fiveSecondsLeftSpeechTextField.text = exercise.speech?.fiveSecondsLeft
                endSpeechTextField.text = exercise.speech?.end
//                descriptionTextView.text = exercise.exerciseDescription
            }
        }

        // Hide keyboard.
        // TODO: Refactor. Not working for description.
        nameTextField.delegate = self
        startSpeechTextField.delegate = self
        thirtySecondsLeftSpeechTextField.delegate = self
        tenSecondsLeftSpeechTextField.delegate = self
        fiveSecondsLeftSpeechTextField.delegate = self
        endSpeechTextField.delegate = self
//        descriptionTextView.delegate = self

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
        return 5
    }
/**/
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

        // TODO: Enum! I don't even know what it is.
        if section == 3 {
            return 5
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
