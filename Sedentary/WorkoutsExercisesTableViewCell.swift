//
//  WorkoutsTableViewCell.swift
//  Sedentary
//
//  Created by vt on 10/6/17.
//  Copyright © 2017 Vasiliy Tokarev. All rights reserved.
//

import UIKit

class WorkoutsExercisesTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    func update(with workout: Workout) {
        nameLabel.text = workout.name
    }
    
    func update(with text: String) {
        nameLabel.text = text
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
