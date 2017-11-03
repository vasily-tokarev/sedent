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
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBAction func durationStepperValueChanged(_ sender: UIStepper) {
        let seconds = Int(durationStepper.value)
        let (h, m, s) = secondsToHoursMinutesSeconds(seconds: seconds)
        durationLabel.text = String(format: "%02i:%02i", m, s)

        // Hide thirtySecondsSpeech
//        if durationStepper.value < 60.0 {
//            thirtySecondsLeftSpeechTextField.isEnabled = false
//        } else {
//            thirtySecondsLeftSpeechTextField.isEnabled = true
//        }
    }

    func secondsToHoursMinutesSeconds (seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    @objc func saveButtonTapped() {
        func saveImage(image: UIImage, path: URL ) {
            let pngImageData = UIImagePNGRepresentation(image)
            //let jpgImageData = UIImageJPEGRepresentation(image, 1.0)   // if you want to save as JPEG
//            let result = pngImageData!.writeToFile(path, atomically: true)
            try? pngImageData!.write(to: path)
        }

        let exercise = Exercise (
                id: currentExercise?.id,
                name: nameTextField.text!.isEmpty ? "Exercise" : nameTextField.text!,
                duration: Int(durationStepper.value),
                speech: Exercise.Speech(start: startSpeechTextField.text ?? "",
                        thirtySecondsLeft: thirtySecondsLeftSpeechTextField.text ?? "",
                        tenSecondsLeft: tenSecondsLeftSpeechTextField.text ?? "",
                        fiveSecondsLeft: fiveSecondsLeftSpeechTextField.text ?? "",
                        end: endSpeechTextField.text ?? ""
                ),
                description: descriptionTextField.text ?? ""
        )

        if let _ = currentExercise {
            state.exercises[selectedExerciseIndex!] = exercise
        } else {
            state.exercises.append(exercise)
        }

        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let imageURL = docDir.appendingPathComponent("\(exercise.name)-\(exercise.id)-0.png")

        if let image = imageView.image {
            let _ = saveImage(image: image, path: imageURL)
        }

        state.exercises.save()
        state.enabledExercises.delete(exercise: exercise)
        state.workouts.refresh()
        performSegue(withIdentifier: Navigation.Segue.unwindToWorkoutsExercises.identifier, sender: self)
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

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)

        self.tableView.separatorStyle = .none

        let saveButtonItem: UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.saveButtonTapped))
        navigationItem.rightBarButtonItem = saveButtonItem

        formatDuration(value: durationStepper.value)
        if let selectedExerciseIndex = selectedExerciseIndex {
            currentExercise = state.exercises[selectedExerciseIndex]
            if let exercise = currentExercise {
                guard let docDir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
                    print("ExercisesTableViewController: docDir is not set")
                    return
                }
                let imageURL = docDir.appendingPathComponent("\(exercise.name)-\(exercise.id)-0.png")
                if let data = try? Data(contentsOf: imageURL) {
                    imageView.image = UIImage(data: data)
                }

                nameTextField.text! = exercise.name
                durationStepper.value = Double(exercise.duration)
//                durationLabel.text = String(exercise.duration)
                formatDuration(value: Double(exercise.duration))
                startSpeechTextField.text = exercise.speech.start
                thirtySecondsLeftSpeechTextField.text = exercise.speech.thirtySecondsLeft
                tenSecondsLeftSpeechTextField.text = exercise.speech.tenSecondsLeft
                fiveSecondsLeftSpeechTextField.text = exercise.speech.fiveSecondsLeft
                endSpeechTextField.text = exercise.speech.end
                descriptionTextField.text = exercise.description
            }
        }

        // Hide keyboard.
        nameTextField.delegate = self
        descriptionTextField.delegate = self
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

//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    @objc func imageViewTapped(tapGestureRecognizer: UITapGestureRecognizer) {
            let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)

            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self

//            if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                print("camera available")
//                let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {
//                    action in
//                    imagePicker.sourceType = .camera
//                    self.present(imagePicker, animated: true, completion: nil)
//                })
//                alertController.addAction(cameraAction)
//            }

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

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = selectedImage
            dismiss(animated: true, completion: nil)
        }
    }
}
