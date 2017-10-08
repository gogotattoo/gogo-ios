//
//  ArtWorkMatrixViewModel.swift
//  gogo-ios
//
//  Created by Hongli Yu on 04/10/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation

class ArtWorkMatrixViewModel {
  
  fileprivate(set) var artType: ArtType = .tattoo
  fileprivate(set) var artWorkFilteredViewModels: [ArtWorkSectionViewModel] = []
    
  init(artType: ArtType, artWorkFilteredViewModels: [ArtWorkSectionViewModel]) {
    self.artType = artType
    self.artWorkFilteredViewModels = artWorkFilteredViewModels
  }
  
}

extension ArtWorkMatrixViewModel: Equatable {
  
  static func ==(lhs: ArtWorkMatrixViewModel, rhs: ArtWorkMatrixViewModel) -> Bool {
    return lhs.artType == rhs.artType
  }
  
}
