//
//  Note.swift
//  RPOdMP-BonusLab
//
//  Created by Alex Azarov on 2/2/19.
//  Copyright © 2019 Alex Azarov. All rights reserved.
//

import ObjectMapper

struct Note {
    let title: String
    let content: String
    let id: Int
    
    init(title: String, content: String) {
        self.title = title
        self.content = content
        self.id = 0
    }
}

extension Note: ImmutableMappable {
    
    init(map: Map) throws {
        title = try map.value("title")
        content = try map.value("content")
        id = try map.value("id")
    }
    
    func mapping(map: Map) {
        title >>> map["title"]
        content >>> map["content"]
        id >>> map["id"]
    }
}
