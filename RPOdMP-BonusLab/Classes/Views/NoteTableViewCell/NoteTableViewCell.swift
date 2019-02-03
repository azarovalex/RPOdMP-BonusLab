//
//  NoteTableViewCell.swift
//  RPOdMP-BonusLab
//
//  Created by Alex Azarov on 2/3/19.
//  Copyright © 2019 Alex Azarov. All rights reserved.
//

import UIKit

struct NoteTableViewCellModel {
    let title: String
    let content: String
}

class NoteTableViewCell: UITableViewCell {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var contentLabel: UILabel!
    
    private var deleteCallback: (() -> Void)?
    
    func configure(with model: NoteTableViewCellModel, deleteCallback: @escaping () -> Void) {
        titleLabel.text = model.title
        contentLabel.text = model.content
        self.deleteCallback = deleteCallback
    }
    
    @IBAction func deleteNote(_ sender: Any) {
        deleteCallback?()
    }
}
