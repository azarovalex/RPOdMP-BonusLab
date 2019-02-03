//
//  NoteAPI.swift
//  RPOdMP-BonusLab
//
//  Created by Alex Azarov on 2/2/19.
//  Copyright © 2019 Alex Azarov. All rights reserved.
//

import Moya

enum NotesAPI {
    case createNote(model: Note)
    case getNotes
    case deleteNote(id: Int)
}

extension NotesAPI: TargetType {
    
    var baseURL: URL {
        return Credentials.Backend.serverURL
    }
    
    var path: String {
        switch self {
        case .createNote, .getNotes:
            return "/notes"
        case .deleteNote(let id):
            return "/notes/\(id)"
        }
    }
    
    var method: Method {
        switch self {
        case .createNote:
            return .post
        case .getNotes:
            return .get
        case .deleteNote:
            return .delete
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .getNotes, .deleteNote:
            return .requestPlain
        case .createNote(let model):
            return .requestParameters(parameters: ["title": model.title, "content": model.content],
                                      encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}

