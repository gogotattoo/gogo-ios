//
//  ArtWorkSectionViewModel.swift
//  gogo-ios
//
//  Created by Hongli Yu on 04/10/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation

class ArtWorkSectionViewModel {
  
  fileprivate(set) var title: String = ""
  fileprivate(set) var height: CGFloat = 0
  fileprivate(set) var artWorkViewModels: [Any] = []
  
  init(title: String, height: CGFloat, artWorkViewModels: [Any]) {
    self.title = title
    self.height = height
    self.artWorkViewModels = artWorkViewModels
  }
  
}

extension ArtWorkSectionViewModel: Equatable {
  
  static func ==(lhs: ArtWorkSectionViewModel, rhs: ArtWorkSectionViewModel) -> Bool {
    return lhs.title == rhs.title
  }
  
}
