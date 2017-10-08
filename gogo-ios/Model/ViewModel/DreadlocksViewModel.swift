//
//  DreadlocksViewModel.swift
//  gogo-ios
//
//  Created by Hongli Yu on 25/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation
import SwiftDate
import UIKit

class DreadlocksViewModel {
  fileprivate var dreadlocks: Dreadlocks = Dreadlocks()
  
  fileprivate(set) var identifier: String = ""
  fileprivate(set) var link: String = ""
  fileprivate(set) var title: String = ""
  fileprivate(set) var madeDate: Date = Date()
  fileprivate(set) var date: Date = Date()
  fileprivate(set) var imageIPFS: String = ""
  fileprivate(set) var madeAtCountry: String = ""
  fileprivate(set) var madeAtCity: String = ""
  fileprivate(set) var madeAtShop: String = ""
  fileprivate(set) var durationMin: Int = 0
  fileprivate(set) var gender: String = ""
  fileprivate(set) var extra: String = ""
  
  fileprivate(set) var tags: [String] = []
  fileprivate(set) var bodypart: [String] = []
  fileprivate(set) var imagesIPFS: [String] = []
  fileprivate(set) var videosIPFS: [String] = []
  fileprivate(set) var blockChain: BlockChain = BlockChain()

  // custom properties
  fileprivate(set) var artType: ArtType = ArtType.tattoo
  fileprivate(set) var artistLink: String = ""
  fileprivate(set) var cellHeight: CGFloat = 0.0
  
  // MARK: Properties Setter
  
  func setCellHeight(cellHeight: CGFloat) {
    self.cellHeight = cellHeight
  }
  
  // MARK: Life Cycle
  required init() {
    
  }
  
  init(json: AnyObject?) {
    self.dreadlocks = Dreadlocks()
    self.dreadlocks.mappingJSONData(json)
    self.syncModelToViewModel()
  }
  
  init(dreadlocks: Dreadlocks?) {
    if dreadlocks != nil {
      self.dreadlocks = dreadlocks!
      self.syncModelToViewModel()
    }
  }
  
  func mappingJSONData(_ json: AnyObject?) {
    self.dreadlocks.mappingJSONData(json)
  }
  
  func fetchArtWork() -> Dreadlocks {
    self.syncViewModelToModel()
    return self.dreadlocks
  }
  
}

// MARK: - CustomStringConvertible
extension DreadlocksViewModel: CustomStringConvertible {
  
  public var description : String {
    return "link: \(self.link), title: \(title) \n"
  }
  
}

// MARK: - Hashable
extension DreadlocksViewModel: Hashable {
  
  var hashValue: Int {
    return (self.identifier + self.link + self.artType.rawValue).hashValue
  }
  
}

// MARK: - Copyable
extension DreadlocksViewModel: Copyable {
  
  func copy() -> Self {
    let result = type(of: self).init()
    result.dreadlocks = self.dreadlocks
    result.identifier = self.identifier
    result.link = self.link
    result.title = self.title
    result.madeDate = self.madeDate
    result.date = self.date
    result.tags = self.tags
    result.bodypart = self.bodypart
    result.imageIPFS = self.imageIPFS
    result.imagesIPFS = self.imagesIPFS
    result.videosIPFS = self.videosIPFS
    result.madeAtCountry = self.madeAtCountry
    result.madeAtCity = self.madeAtCity
    result.madeAtShop = self.madeAtShop
    result.durationMin = self.durationMin
    result.gender = self.gender
    result.extra = self.extra
    if let blockChain = self.blockChain.copy() as? BlockChain {
      result.blockChain = blockChain
    }
    result.artType = self.artType
    result.artistLink = self.artistLink
    result.cellHeight = self.cellHeight
    return result
  }
  
}

// MARK: - Realmable
extension DreadlocksViewModel: Realmable {
  
  func syncViewModelToModel() {
    self.dreadlocks = Dreadlocks()
    
    self.dreadlocks.identifier = self.identifier
    self.dreadlocks.link = self.link
    self.dreadlocks.title = self.title
    self.dreadlocks.imageIPFS = self.imageIPFS
    self.dreadlocks.madeDate = self.madeDate.string(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))
    self.dreadlocks.date = self.date.string(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))
    self.dreadlocks.tags.append(objectsIn: (self.tags).map({ RealmString(value: [$0]) }))
    self.dreadlocks.bodypart.append(objectsIn: (self.bodypart).map({ RealmString(value: [$0]) }))
    self.dreadlocks.imagesIPFS.append(objectsIn: (self.imagesIPFS).map({ RealmString(value: [$0]) }))
    self.dreadlocks.videosIPFS.append(objectsIn: (self.videosIPFS).map({ RealmString(value: [$0]) }))
    self.dreadlocks.madeAtCity = self.madeAtCity
    self.dreadlocks.madeAtShop = self.madeAtShop
    self.dreadlocks.durationMin = self.durationMin
    self.dreadlocks.gender = self.gender
    self.dreadlocks.extra = self.extra
    self.dreadlocks.artType = self.artType.rawValue
    self.dreadlocks.artistLink = self.artistLink
    self.dreadlocks.cellHeight = Float(self.cellHeight)
  }
  
  func syncModelToViewModel() {
    self.identifier = self.dreadlocks.identifier
    self.link = self.dreadlocks.link
    self.title = self.dreadlocks.title
    if let date = self.dreadlocks.madeDate.date(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))?.absoluteDate {
      self.madeDate = date
    }
    if let date = self.dreadlocks.date.date(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))?.absoluteDate {
      self.date = date
    }
    for tag: RealmString in self.dreadlocks.tags {
      self.tags.append(tag.stringValue)
    }
    for bodypart: RealmString in self.dreadlocks.bodypart {
      self.bodypart.append(bodypart.stringValue)
    }
    self.imageIPFS = self.dreadlocks.imageIPFS
    for imageIPFS: RealmString in self.dreadlocks.imagesIPFS {
      self.imagesIPFS.append(imageIPFS.stringValue)
    }
    self.madeAtCountry = self.dreadlocks.madeAtCountry
    self.madeAtCity = self.dreadlocks.madeAtCity
    self.madeAtShop = self.dreadlocks.madeAtShop
    self.durationMin = self.dreadlocks.durationMin
    self.gender = self.dreadlocks.gender
    self.extra = self.dreadlocks.extra
    if let blockChain = self.dreadlocks.blockChain?.copy() as? BlockChain {
      self.blockChain = blockChain
    }
    if let artType = ArtType(rawValue: self.dreadlocks.artType) {
      self.artType = artType
    }
    self.artistLink = self.dreadlocks.artistLink
    self.cellHeight = CGFloat(self.dreadlocks.cellHeight)
  }
  
}

extension DreadlocksViewModel: Equatable {
  
  static func ==(lhs: DreadlocksViewModel, rhs: DreadlocksViewModel) -> Bool {
    return lhs.identifier == rhs.identifier
  }
  
}
