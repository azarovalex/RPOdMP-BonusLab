//
//  EditNoteViewController.swift
//  RPOdMP-BonusLab
//
//  Created by Alex Azarov on 2/5/19.
//  Copyright © 2019 Alex Azarov. All rights reserved.
//

import RxSwift
import RxCocoa

class EditNoteViewController: UIViewController {

    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var contentTextView: UITextView!
    @IBOutlet private var editButton: UIBarButtonItem!
    
    private let viewModel = EditNoteViewModel()
    private let bag = DisposeBag()
    
    var note: Note!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.text = note.title
        contentTextView.text = note.content
        setup()
        
    }
}

private extension EditNoteViewController {
    
    func setup() {
        let inputs = EditNoteViewModel.Input(title: titleTextField.rx.text.orEmpty.asDriver(),
                                            content: contentTextView.rx.text.orEmpty.asDriver(),
                                            editButton: editButton.rx.tap.asSignal(),
                                            oldNoteID: note.id)
        let outputs = viewModel.transform(input: inputs)
        outputs.errors
            .emit(to: rx.error)
            .disposed(by: bag)
        outputs.isLoading
            .drive(rx.isLoading)
            .disposed(by: bag)
        outputs.isEditButtonEnabled
            .drive(editButton.rx.isEnabled)
            .disposed(by: bag)
        outputs.navigation
            .emit(onNext: { self.navigationController?.popViewController(animated: true) })
            .disposed(by: bag)
    }
}
