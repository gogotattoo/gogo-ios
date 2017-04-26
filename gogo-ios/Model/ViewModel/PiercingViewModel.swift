//
//  PiercingViewModel.swift
//  gogo-ios
//
//  Created by Hongli Yu on 25/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation
import SwiftDate
import UIKit

class PiercingViewModel {
    fileprivate var piercing: Piercing = Piercing()
    
    fileprivate(set) var identifier: String = ""
    fileprivate(set) var link: String = ""
    fileprivate(set) var title: String = ""
    fileprivate(set) var madeDate: Date = Date()
    fileprivate(set) var date: Date = Date()
    fileprivate(set) var tags: [String] = []
    fileprivate(set) var bodypart: [String] = []
    fileprivate(set) var imageIPFS: String = ""
    fileprivate(set) var imagesIPFS: [String] = []
    fileprivate(set) var madeAtCountry: String = ""
    fileprivate(set) var madeAtCity: String = ""
    fileprivate(set) var madeAtShop: String = ""
    fileprivate(set) var durationMin: Int = 0
    fileprivate(set) var gender: String = ""
    fileprivate(set) var extra: String = ""
    
    // custom properties
    fileprivate(set) var artistType: ArtistType = ArtistType.tattoo
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
        self.piercing = Piercing()
        self.piercing.mappingJSONData(json)
        self.syncModelToViewModel()
    }
    
    init(piercing: Piercing?) {
        if piercing != nil {
            self.piercing = piercing!
            self.syncModelToViewModel()
        }
    }
    
    func mappingJSONData(_ json: AnyObject?) {
        self.piercing.mappingJSONData(json)
    }
    
    func fetchArtWork() -> Piercing {
        self.syncViewModelToModel()
        return self.piercing
    }

}

// MARK: - CustomStringConvertible
extension PiercingViewModel: CustomStringConvertible {
    
    public var description : String {
        return "link: \(self.link), title: \(title) \n"
    }
    
}

// MARK: - Hashable
extension PiercingViewModel: Hashable {
    
    var hashValue : Int {
        get {
            return (self.identifier.hashValue)
        }
    }
    
}

// MARK: - Copyable
extension PiercingViewModel: Copyable {
    
    func copy() -> Self {
        let result = type(of: self).init()
        result.piercing = self.piercing
        result.identifier = self.identifier
        result.link = self.link
        result.title = self.title
        result.madeDate = self.madeDate
        result.date = self.date
        result.tags = self.tags
        result.bodypart = self.bodypart
        result.imageIPFS = self.imageIPFS
        result.imagesIPFS = self.imagesIPFS
        result.madeAtCountry = self.madeAtCountry
        result.madeAtCity = self.madeAtCity
        result.madeAtShop = self.madeAtShop
        result.durationMin = self.durationMin
        result.gender = self.gender
        result.extra = self.extra
        result.artistType = self.artistType
        result.artistLink = self.artistLink
        result.cellHeight = self.cellHeight
        return result
    }
    
}

// MARK: - Realmable
extension PiercingViewModel: Realmable {
    
    func syncViewModelToModel() {
        self.piercing = Piercing() // TODO: May cause problems, check it out
        
        self.piercing.identifier = self.identifier
        self.piercing.link = self.link
        self.piercing.title = self.title
        self.piercing.madeDate = self.madeDate.string(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))
        self.piercing.date = self.date.string(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))
        self.piercing.tags.append(objectsIn: (self.tags).map({ RealmString(value: [$0]) }))
        self.piercing.bodypart.append(objectsIn: (self.bodypart).map({ RealmString(value: [$0]) }))
        self.piercing.imageIPFS = self.imageIPFS
        self.piercing.imagesIPFS.append(objectsIn: (self.imagesIPFS).map({ RealmString(value: [$0]) }))
        self.piercing.madeAtCity = self.madeAtCity
        self.piercing.madeAtShop = self.madeAtShop
        self.piercing.durationMin = self.durationMin
        self.piercing.gender = self.gender
        self.piercing.extra = self.extra
        self.piercing.artistType = self.artistType.rawValue
        self.piercing.artistLink = self.artistLink
        self.piercing.cellHeight = Float(self.cellHeight)
        
    }
    
    func syncModelToViewModel() {
        self.identifier = self.piercing.identifier
        self.link = self.piercing.link
        self.title = self.piercing.title
        if let date = self.piercing.madeDate.date(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))?.absoluteDate {
            self.madeDate = date
        }
        if let date = self.piercing.date.date(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))?.absoluteDate {
            self.date = date
        }
        for tag: RealmString in self.piercing.tags {
            self.tags.append(tag.stringValue)
        }
        for bodypart: RealmString in self.piercing.bodypart {
            self.bodypart.append(bodypart.stringValue)
        }
        self.imageIPFS = self.piercing.imageIPFS
        for imageIPFS: RealmString in self.piercing.imagesIPFS {
            self.imagesIPFS.append(imageIPFS.stringValue)
        }
        self.madeAtCountry = self.piercing.madeAtCountry
        self.madeAtCity = self.piercing.madeAtCity
        self.madeAtShop = self.piercing.madeAtShop
        self.durationMin = self.piercing.durationMin
        self.gender = self.piercing.gender
        self.extra = self.piercing.extra
        if let artistType = ArtistType(rawValue: self.piercing.artistType) {
            self.artistType = artistType
        }
        self.artistLink = self.piercing.artistLink
        self.cellHeight = CGFloat(self.piercing.cellHeight)
    }
    
}

extension PiercingViewModel: Equatable {
    
    static func ==(lhs: PiercingViewModel, rhs: PiercingViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
}
