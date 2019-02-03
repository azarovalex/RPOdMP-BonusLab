//
//  AppError.swift
//  RPOdMP-BonusLab
//
//  Created by Alex Azarov on 2/2/19.
//  Copyright © 2019 Alex Azarov. All rights reserved.
//

import Foundation

protocol AppError: Error {
    var message: String { get }
    init(message: String)
}

struct EmptyError: Error {
    
}
