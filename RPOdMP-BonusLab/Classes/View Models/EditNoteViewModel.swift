//
//  EditNoteViewModel.swift
//  RPOdMP-BonusLab
//
//  Created by Alex Azarov on 2/5/19.
//  Copyright © 2019 Alex Azarov. All rights reserved.
//

import RxCocoa
import RxSwift

class EditNoteViewModel {
    
    private let notesService = NotesService()
    private let errorsRelay = PublishRelay<Error>()
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    
    struct Input {
        let title: Driver<String>
        let content: Driver<String>
        let editButton: Signal<Void>
        let oldNoteID: Int
    }
    
    struct Output {
        let navigation: Signal<Void>
        let isLoading: Driver<Bool>
        let errors: Signal<Error>
        let isEditButtonEnabled: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        let isEditButtonEnabled = Driver.combineLatest(input.title, input.content, resultSelector: { !$0.isEmpty && !$1.isEmpty })
        let navigationSignal = getNavigationSignal(input: input)
        return Output(navigation: navigationSignal,
                      isLoading: isLoadingRelay.asDriver(),
                      errors: errorsRelay.asSignal(),
                      isEditButtonEnabled: isEditButtonEnabled)
    }

    private func getNavigationSignal(input: Input) -> Signal<Void> {
        let noteDriver = Driver.combineLatest(input.title, input.content) { Note(title: $0, content: $1) }
        return input.editButton.withLatestFrom(noteDriver).flatMap { [unowned self] newNote -> Signal<Void> in
            self.isLoadingRelay.accept(true)
            return self.notesService.deleteNote(with: input.oldNoteID)
                .flatMap { result -> Single<Void> in
                    if let error = result.error { return .error(error) }
                    guard result.value != nil else { return .error(EmptyError()) }
                    return .just(()) }
                .flatMap { _ -> Single<Void> in
                    return self.notesService.createNote(model: newNote).flatMap { result -> Single<Void> in
                        if let error = result.error { return .error(error) }
                        guard result.value != nil else { return .error(EmptyError()) }
                        return .just(()) } }
                .asSignal(onErrorRecover: { [unowned self] error -> Signal<()> in
                    self.errorsRelay.accept(error)
                    return .never() }) }
    }
}
