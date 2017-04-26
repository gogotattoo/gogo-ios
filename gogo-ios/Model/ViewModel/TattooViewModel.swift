//
//  TattooViewModel.swift
//  gogo-ios
//
//  Created by Hongli Yu on 25/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation
import SwiftDate
import UIKit

class TattooViewModel {
    
    fileprivate var tattoo: Tattoo = Tattoo()
    
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
        self.tattoo = Tattoo()
        self.tattoo.mappingJSONData(json)
        self.syncModelToViewModel()
    }
    
    init(tattoo: Tattoo?) {
        if tattoo != nil {
            self.tattoo = tattoo!
            self.syncModelToViewModel()
        }
    }
    
    func mappingJSONData(_ json: AnyObject?) {
        self.tattoo.mappingJSONData(json)
    }
    
    func fetchArtWork() -> Tattoo {
        self.syncViewModelToModel()
        return self.tattoo
    }

}

// MARK: - CustomStringConvertible
extension TattooViewModel: CustomStringConvertible {
    
    public var description : String {
        return "link: \(self.link), title: \(title) \n"
    }
    
}

// MARK: - Hashable
extension TattooViewModel: Hashable {
    
    var hashValue : Int {
        get {
            return (self.identifier.hashValue)
        }
    }
    
}

// MARK: - Copyable
extension TattooViewModel: Copyable {
    
    func copy() -> Self {
        let result = type(of: self).init()
        result.tattoo = self.tattoo
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
extension TattooViewModel: Realmable {
    
    func syncViewModelToModel() {
        self.tattoo = Tattoo() // TODO: May cause problems, check it out
        
        self.tattoo.identifier = self.identifier
        self.tattoo.link = self.link
        self.tattoo.title = self.title
        self.tattoo.madeDate = self.madeDate.string(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))
        self.tattoo.date = self.date.string(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))
        self.tattoo.tags.append(objectsIn: (self.tags).map({ RealmString(value: [$0]) }))
        self.tattoo.bodypart.append(objectsIn: (self.bodypart).map({ RealmString(value: [$0]) }))
        self.tattoo.imageIPFS = self.imageIPFS
        self.tattoo.imagesIPFS.append(objectsIn: (self.imagesIPFS).map({ RealmString(value: [$0]) }))
        self.tattoo.madeAtCountry = self.madeAtCountry
        self.tattoo.madeAtCity = self.madeAtCity
        self.tattoo.madeAtShop = self.madeAtShop
        self.tattoo.durationMin = self.durationMin
        self.tattoo.gender = self.gender
        self.tattoo.extra = self.extra
        self.tattoo.artistType = self.artistType.rawValue
        self.tattoo.artistLink = self.artistLink
        self.tattoo.cellHeight = Float(self.cellHeight)
        
    }
    
    func syncModelToViewModel() {
        self.identifier = self.tattoo.identifier
        self.link = self.tattoo.link
        self.title = self.tattoo.title
        if let date = self.tattoo.madeDate.date(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))?.absoluteDate {
            self.madeDate = date
        }
        if let date = self.tattoo.date.date(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))?.absoluteDate {
            self.date = date
        }
        for tag: RealmString in self.tattoo.tags {
            self.tags.append(tag.stringValue)
        }
        for bodypart: RealmString in self.tattoo.bodypart {
            self.bodypart.append(bodypart.stringValue)
        }
        self.imageIPFS = self.tattoo.imageIPFS
        for imageIPFS: RealmString in self.tattoo.imagesIPFS {
            self.imagesIPFS.append(imageIPFS.stringValue)
        }
        self.madeAtCountry = self.tattoo.madeAtCountry
        self.madeAtCity = self.tattoo.madeAtCity
        self.madeAtShop = self.tattoo.madeAtShop
        self.durationMin = self.tattoo.durationMin
        self.gender = self.tattoo.gender
        self.extra = self.tattoo.extra
        if let artistType = ArtistType(rawValue: self.tattoo.artistType) {
            self.artistType = artistType
        }
        self.artistLink = self.tattoo.artistLink
        self.cellHeight = CGFloat(self.tattoo.cellHeight)
    }
    
}

extension TattooViewModel: Equatable {
    
    static func ==(lhs: TattooViewModel, rhs: TattooViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
}
