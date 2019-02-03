//
//  ViewController.swift
//  RPOdMP-BonusLab
//
//  Created by Alex Azarov on 2/2/19.
//  Copyright © 2019 Alex Azarov. All rights reserved.
//

import RxSwift
import RxCocoa

class ListOfNotesViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var newNoteButton: UIBarButtonItem!
    
    private let deleteCellRelay = PublishRelay<Int>()
    private let viewModel = ListOfNotesViewModel()
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

// MARK: - Setup
private extension ListOfNotesViewController {
    
    func setup() {
        bindViewModel()
        tableView.register(R.nib.noteTableViewCell)
    }
    
    func bindViewModel() {
        let inputs = ListOfNotesViewModel.Input(noteDeleted: deleteCellRelay.asSignal(),
                                                newNote: newNoteButton.rx.tap.asSignal(),
                                                viewWillAppear: rx.viewWillAppear.asSignal())
        let outputs = viewModel.transform(input: inputs)
        
        outputs.navigation
            .emit(to: navigation)
            .disposed(by: bag)
        outputs.isLoading
            .drive(rx.isLoading)
            .disposed(by: bag)
        outputs.errors
            .emit(to: rx.error)
            .disposed(by: bag)
        outputs.cells
            .drive(tableView.rx.items) { [weak self] _, index, model in
                guard let self = self else { return UITableViewCell() }
                return self.getCell(for: index, with: model) }
            .disposed(by: bag)
    }
}

// MARK: - Private
private extension ListOfNotesViewController {
    
    func getCell(for index: Int, with model: NoteTableViewCellModel) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noteTableViewCell, for: IndexPath(row: index, section: 0)) else { return UITableViewCell() }
        cell.configure(with: model) { [unowned self] in self.deleteCellRelay.accept(index) }
        return cell
    }
}

// MARK: - Navigation
private extension ListOfNotesViewController {
    
    var navigation: Binder<Void> {
        return Binder<Void>.init(self, binding: { (viewController, _) in
            let newNoteViewController = R.storyboard.main.newNoteViewController()!
            viewController.navigationController?.pushViewController(newNoteViewController, animated: true)
        })
    }
}
