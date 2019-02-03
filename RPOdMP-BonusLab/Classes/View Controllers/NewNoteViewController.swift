//
//  NewNoteViewController.swift
//  RPOdMP-BonusLab
//
//  Created by Alex Azarov on 2/3/19.
//  Copyright © 2019 Alex Azarov. All rights reserved.
//

import RxSwift
import RxCocoa

class NewNoteViewController: UIViewController {

    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var contentTextView: UITextView!
    @IBOutlet private var publishButton: UIBarButtonItem!
    
    private let viewModel = NewNoteViewModel()
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
}

// MARK: - Setup
private extension NewNoteViewController {
    
    func setup() {
        let inputs = NewNoteViewModel.Input(title: titleTextField.rx.text.orEmpty.asDriver(),
                                           content: contentTextView.rx.text.orEmpty.asDriver(),
                                           publish: publishButton.rx.tap.asSignal())
        let outputs = viewModel.transform(input: inputs)
        
        outputs.errors
            .emit(to: rx.error)
            .disposed(by: bag)
        outputs.isLoading
            .drive(rx.isLoading)
            .disposed(by: bag)
        outputs.navigation
            .emit(to: navigation)
            .disposed(by: bag)
        outputs.isPublishButtonActive
            .drive(publishButton.rx.isEnabled)
            .disposed(by: bag)
    }
}

// MARK: - Navigation
private extension NewNoteViewController {
    
    var navigation: Binder<Void> {
        return Binder<Void>.init(self, binding: { (viewController, _) in
            viewController.navigationController?.popViewController(animated: true)
        })
    }
}
