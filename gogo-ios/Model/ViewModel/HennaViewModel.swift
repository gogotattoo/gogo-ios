//
//  HennaViewModel.swift
//  gogo-ios
//
//  Created by Hongli Yu on 25/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation
import SwiftDate
import UIKit

class HennaViewModel {
    fileprivate var henna: Henna = Henna()
    
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
        self.henna = Henna()
        self.henna.mappingJSONData(json)
        self.syncModelToViewModel()
    }
    
    init(henna: Henna?) {
        if henna != nil {
            self.henna = henna!
            self.syncModelToViewModel()
        }
    }
    
    func mappingJSONData(_ json: AnyObject?) {
        self.henna.mappingJSONData(json)
    }
    
    func fetchArtWork() -> Henna {
        self.syncViewModelToModel()
        return self.henna
    }

}

// MARK: - CustomStringConvertible
extension HennaViewModel: CustomStringConvertible {
    
    public var description : String {
        return "link: \(self.link), title: \(title) \n"
    }
    
}

// MARK: - Hashable
extension HennaViewModel: Hashable {
    
    var hashValue : Int {
        get {
            return (self.identifier.hashValue)
        }
    }
    
}

// MARK: - Copyable
extension HennaViewModel: Copyable {
    
    func copy() -> Self {
        let result = type(of: self).init()
        result.henna = self.henna
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
extension HennaViewModel: Realmable {
    
    func syncViewModelToModel() {
        self.henna = Henna() // TODO: May cause problems, check it out
        
        self.henna.identifier = self.identifier
        self.henna.link = self.link
        self.henna.title = self.title
        self.henna.madeDate = self.madeDate.string(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))
        self.henna.date = self.date.string(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))
        self.henna.tags.append(objectsIn: (self.tags).map({ RealmString(value: [$0]) }))
        self.henna.bodypart.append(objectsIn: (self.bodypart).map({ RealmString(value: [$0]) }))
        self.henna.imageIPFS = self.imageIPFS
        self.henna.imagesIPFS.append(objectsIn: (self.imagesIPFS).map({ RealmString(value: [$0]) }))
        self.henna.madeAtCountry = self.madeAtCountry
        self.henna.madeAtCity = self.madeAtCity
        self.henna.madeAtShop = self.madeAtShop
        self.henna.durationMin = self.durationMin
        self.henna.gender = self.gender
        self.henna.extra = self.extra
        self.henna.artistType = self.artistType.rawValue
        self.henna.artistLink = self.artistLink
        self.henna.cellHeight = Float(self.cellHeight)
        
    }
    
    func syncModelToViewModel() {
        self.identifier = self.henna.identifier
        self.link = self.henna.link
        self.title = self.henna.title
        if let date = self.henna.madeDate.date(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))?.absoluteDate {
            self.madeDate = date
        }
        if let date = self.henna.date.date(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))?.absoluteDate {
            self.date = date
        }
        for tag: RealmString in self.henna.tags {
            self.tags.append(tag.stringValue)
        }
        for bodypart: RealmString in self.henna.bodypart {
            self.bodypart.append(bodypart.stringValue)
        }
        self.imageIPFS = self.henna.imageIPFS
        for imageIPFS: RealmString in self.henna.imagesIPFS {
            self.imagesIPFS.append(imageIPFS.stringValue)
        }
        self.madeAtCountry = self.henna.madeAtCountry
        self.madeAtCity = self.henna.madeAtCity
        self.madeAtShop = self.henna.madeAtShop
        self.durationMin = self.henna.durationMin
        self.gender = self.henna.gender
        self.extra = self.henna.extra
        if let artistType = ArtistType(rawValue: self.henna.artistType) {
            self.artistType = artistType
        }
        self.artistLink = self.henna.artistLink
        self.cellHeight = CGFloat(self.henna.cellHeight)
    }
    
}

extension HennaViewModel: Equatable {
    
    static func ==(lhs: HennaViewModel, rhs: HennaViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
}

