//
//  ListOfNotesViewModel.swift
//  RPOdMP-BonusLab
//
//  Created by Alex Azarov on 2/2/19.
//  Copyright © 2019 Alex Azarov. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

class ListOfNotesViewModel {
    
    private let errorsRelay = PublishRelay<Error>()
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let notesService = NotesService()
    private let bag = DisposeBag()
    
    private var notesStorage = BehaviorRelay<[Note]>(value: [])
    
    struct Input {
        let noteDeleted: Signal<Int>
        let newNote: Signal<Void>
        let viewWillAppear: Signal<Void>
    }
    
    struct Output {
        let navigation: Signal<Void>
        let cells: Driver<[NoteTableViewCellModel]>
        let isLoading: Driver<Bool>
        let errors: Signal<Error>
    }
    
    func transform(input: Input) -> Output {
        let navigationSignal = input.newNote
        let cellsDriver = notesStorage.asDriver()
            .map { $0.map { NoteTableViewCellModel(title: $0.title, content: $0.content) } }
        bindEvents(input: input)
        return Output(navigation: navigationSignal,
                      cells: cellsDriver,
                      isLoading: isLoadingRelay.asDriver(),
                      errors: errorsRelay.asSignal())
    }
}

// MARK: - Private
private extension ListOfNotesViewModel {
    
    func bindEvents(input: Input) {
        let noteDeleted = input.noteDeleted.flatMap { (index) -> Signal<Void> in
            let noteToDelete = self.notesStorage.value[index]
            self.isLoadingRelay.accept(true)
            return self.notesService.deleteNote(with: noteToDelete.id)
                .flatMap { result -> Single<Void> in
                    if let error = result.error { return .error(error) }
                    guard let sucess = result.value else { return .error(EmptyError()) }
                    return .just(sucess) }
                .asSignal(onErrorRecover: { [unowned self] error -> Signal<Void> in
                    self.errorsRelay.accept(error)
                    return .never()
                })
        }
        
        let localStorageUpdateSignal = Signal.merge(input.viewWillAppear, noteDeleted)
        localStorageUpdateSignal.flatMap { [unowned self] _ -> Driver<[Note]> in
            return self.notesService.getNotes()
                .do { [unowned self] in self.isLoadingRelay.accept(true) }
                .flatMap({ result -> Single<[Note]> in
                    if let error = result.error { return .error(error) }
                    guard let notes = result.value else { return .error(EmptyError()) }
                    return .just(notes) })
                .do { [unowned self] in self.isLoadingRelay.accept(false) }
                .asDriver(onErrorRecover: { [unowned self] error -> Driver<[Note]> in
                    self.errorsRelay.accept(error)
                    return .never() })
        }.drive(notesStorage)
        .disposed(by: bag)
    }
}

