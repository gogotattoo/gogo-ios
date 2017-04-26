//
//  ArtWorkFilteredListViewModel.swift
//  gogo-ios
//
//  Created by Hongli Yu on 20/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation

class ArtWorkFilteredListViewModel {
    
    fileprivate(set) var artistType: ArtistType = .tattoo
    fileprivate(set) var artWorkFilteredViewModels: Array<ArtWorkFilteredViewModel> = [] // tattoo, design, henna, piercing, dreadlocks
    
    init() {
        
    }
    
    init(artistType: ArtistType, artWorkFilteredViewModels: Array<ArtWorkFilteredViewModel>) {
        self.artistType = artistType
        self.artWorkFilteredViewModels = artWorkFilteredViewModels
    }
    
}

extension ArtWorkFilteredListViewModel: Equatable {
    
    static func ==(lhs: ArtWorkFilteredListViewModel, rhs: ArtWorkFilteredListViewModel) -> Bool {
        return lhs.artistType == rhs.artistType
    }
    
}
