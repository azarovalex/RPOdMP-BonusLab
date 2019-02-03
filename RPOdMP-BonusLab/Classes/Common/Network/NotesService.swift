//
//  NotesService.swift
//  RPOdMP-BonusLab
//
//  Created by Alex Azarov on 2/2/19.
//  Copyright © 2019 Alex Azarov. All rights reserved.
//

import Moya
import RxSwift

struct NotesService: NetworkService {
    
    typealias API = NotesAPI
    var provider = MoyaProvider<API>()

    
    func createNote(model: Note) -> Single<Result<Note>> {
        return fetchData(.createNote(model: model))
    }
    
    func getNotes() -> Single<Result<[Note]>> {
        return fetchArray(.getNotes)
    }
    
    func deleteNote(with id: Int) -> Single<Result<Void>> {
        return send(.deleteNote(id: id))
    }
}
