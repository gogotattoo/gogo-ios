//
//  ModelProtocol.swift
//  gogo-ios
//
//  Created by Hongli Yu on 15/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation

protocol Copyable {
    func copy() -> Self
}

protocol Realmable {
    func syncViewModelToModel()
    func syncModelToViewModel()
}
