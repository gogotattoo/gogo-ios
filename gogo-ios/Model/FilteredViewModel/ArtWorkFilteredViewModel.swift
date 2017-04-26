//
//  ArtWorkFilteredViewModel.swift
//  gogo-ios
//
//  Created by Hongli Yu on 20/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation


class ArtWorkFilteredViewModel {
    
    fileprivate(set) var sectionTitle: String = ""
    fileprivate(set) var artWorkViewModels: [AnyObject] = []
    
    init() {
        
    }
    
    init(sectionTitle: String, artWorkViewModels: [AnyObject]) {
        self.sectionTitle = sectionTitle
        self.artWorkViewModels = artWorkViewModels
    }
    
}

extension ArtWorkFilteredViewModel: Equatable {
    
    static func ==(lhs: ArtWorkFilteredViewModel, rhs: ArtWorkFilteredViewModel) -> Bool {
        return lhs.sectionTitle == rhs.sectionTitle
    }
    
}
