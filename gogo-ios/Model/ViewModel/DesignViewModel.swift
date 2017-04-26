//
//  DesignViewModel.swift
//  gogo-ios
//
//  Created by Hongli Yu on 25/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation
import SwiftDate
import UIKit

class DesignViewModel {
    
    fileprivate var design: Design = Design()
    
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
        self.design = Design()
        self.design.mappingJSONData(json)
        self.syncModelToViewModel()
    }
    
    init(design: Design?) {
        if design != nil {
            self.design = design!
            self.syncModelToViewModel()
        }
    }
    
    func mappingJSONData(_ json: AnyObject?) {
        self.design.mappingJSONData(json)
    }
    
    func fetchArtWork() -> Design {
        self.syncViewModelToModel()
        return self.design
    }

}

// MARK: - CustomStringConvertible
extension DesignViewModel: CustomStringConvertible {
    
    public var description : String {
        return "link: \(self.link), title: \(title) \n"
    }
    
}

// MARK: - Hashable
extension DesignViewModel: Hashable {
    
    var hashValue : Int {
        get {
            return (self.identifier.hashValue)
        }
    }
    
}

// MARK: - Copyable
extension DesignViewModel: Copyable {
    
    func copy() -> Self {
        let result = type(of: self).init()
        result.design = self.design
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
extension DesignViewModel: Realmable {
    
    func syncViewModelToModel() {
        self.design = Design() // TODO: May cause problems, check it out
        
        self.design.identifier = self.identifier
        self.design.link = self.link
        self.design.title = self.title
        self.design.madeDate = self.madeDate.string(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))
        self.design.date = self.date.string(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))
        self.design.tags.append(objectsIn: (self.tags).map({ RealmString(value: [$0]) }))
        self.design.bodypart.append(objectsIn: (self.bodypart).map({ RealmString(value: [$0]) }))
        self.design.imageIPFS = self.imageIPFS
        self.design.imagesIPFS.append(objectsIn: (self.imagesIPFS).map({ RealmString(value: [$0]) }))
        self.design.madeAtCity = self.madeAtCity
        self.design.madeAtShop = self.madeAtShop
        self.design.durationMin = self.durationMin
        self.design.gender = self.gender
        self.design.extra = self.extra
        self.design.artistType = self.artistType.rawValue
        self.design.artistLink = self.artistLink
        self.design.cellHeight = Float(self.cellHeight)
        
    }
    
    func syncModelToViewModel() {
        self.identifier = self.design.identifier
        self.link = self.design.link
        self.title = self.design.title
        if let date = self.design.madeDate.date(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))?.absoluteDate {
            self.madeDate = date
        }
        if let date = self.design.date.date(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))?.absoluteDate {
            self.date = date
        }
        for tag: RealmString in self.design.tags {
            self.tags.append(tag.stringValue)
        }
        for bodypart: RealmString in self.design.bodypart {
            self.bodypart.append(bodypart.stringValue)
        }
        self.imageIPFS = self.design.imageIPFS
        for imageIPFS: RealmString in self.design.imagesIPFS {
            self.imagesIPFS.append(imageIPFS.stringValue)
        }
        self.madeAtCountry = self.design.madeAtCountry
        self.madeAtCity = self.design.madeAtCity
        self.madeAtShop = self.design.madeAtShop
        self.durationMin = self.design.durationMin
        self.gender = self.design.gender
        self.extra = self.design.extra
        if let artistType = ArtistType(rawValue: self.design.artistType) {
            self.artistType = artistType
        }
        self.artistLink = self.design.artistLink
        self.cellHeight = CGFloat(self.design.cellHeight)
    }
    
}

extension DesignViewModel: Equatable {
    
    static func ==(lhs: DesignViewModel, rhs: DesignViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
}
