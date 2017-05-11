//
//  ArtWorkViewModel.swift
//  gogo-ios
//
//  Created by Hongli Yu on 15/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation
import SwiftDate
import UIKit

class ArtWorkViewModel {
    
    fileprivate var artWork: ArtWork = ArtWork()

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
        self.artWork = ArtWork()
        self.artWork.mappingJSONData(json)
        self.syncModelToViewModel()
    }
    
    init(artWork: ArtWork?) {
        if artWork != nil {
            self.artWork = artWork!
            self.syncModelToViewModel()
        }
    }
    
    func mappingJSONData(_ json: AnyObject?) {
        self.artWork.mappingJSONData(json)
    }
    
    func fetchArtWork() -> ArtWork {
        self.syncViewModelToModel()
        return self.artWork
    }

}

// MARK: - CustomStringConvertible
extension ArtWorkViewModel: CustomStringConvertible {
    
    public var description : String {
        return "link: \(self.link), title: \(title) \n"
    }
    
}

// MARK: - Hashable
extension ArtWorkViewModel: Hashable {
    
    var hashValue : Int {
        get {
            return (self.identifier + self.link + self.artistType.rawValue).hashValue
        }
    }
    
}

// MARK: - Copyable
extension ArtWorkViewModel: Copyable {
    
    func copy() -> Self {
        let result = type(of: self).init()
        result.artWork = self.artWork
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
extension ArtWorkViewModel: Realmable {
    
    func syncViewModelToModel() {
        self.artWork = ArtWork() // TODO: May cause problems, check it out
        
        self.artWork.identifier = self.identifier
        self.artWork.link = self.link
        self.artWork.title = self.title
        self.artWork.madeDate = self.madeDate.string(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))
        self.artWork.date = self.date.string(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))
        self.artWork.tags.append(objectsIn: (self.tags).map({ RealmString(value: [$0]) }))
        self.artWork.bodypart.append(objectsIn: (self.bodypart).map({ RealmString(value: [$0]) }))
        self.artWork.imageIPFS = self.imageIPFS
        self.artWork.imagesIPFS.append(objectsIn: (self.imagesIPFS).map({ RealmString(value: [$0]) }))
        self.artWork.madeAtCountry = self.madeAtCountry
        self.artWork.madeAtCity = self.madeAtCity
        self.artWork.madeAtShop = self.madeAtShop
        self.artWork.durationMin = self.durationMin
        self.artWork.gender = self.gender
        self.artWork.extra = self.extra
        self.artWork.artistType = self.artistType.rawValue
        self.artWork.artistLink = self.artistLink
        self.artWork.cellHeight = Float(self.cellHeight)

    }
    
    func syncModelToViewModel() {
        self.identifier = self.artWork.identifier
        self.link = self.artWork.link
        self.title = self.artWork.title
        if let date = self.artWork.madeDate.date(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))?.absoluteDate {
            self.madeDate = date
        }
        if let date = self.artWork.date.date(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))?.absoluteDate {
            self.date = date
        }
        for tag: RealmString in self.artWork.tags {
            self.tags.append(tag.stringValue)
        }
        for bodypart: RealmString in self.artWork.bodypart {
            self.bodypart.append(bodypart.stringValue)
        }
        self.imageIPFS = self.artWork.imageIPFS
        for imageIPFS: RealmString in self.artWork.imagesIPFS {
            self.imagesIPFS.append(imageIPFS.stringValue)
        }
        self.madeAtCountry = self.artWork.madeAtCountry
        self.madeAtCity = self.artWork.madeAtCity
        self.madeAtShop = self.artWork.madeAtShop
        self.durationMin = self.artWork.durationMin
        self.gender = self.artWork.gender
        self.extra = self.artWork.extra
        if let artistType = ArtistType(rawValue: self.artWork.artistType) {
            self.artistType = artistType
        }
        self.artistLink = self.artWork.artistLink
        self.cellHeight = CGFloat(self.artWork.cellHeight)
    }
    
}

extension ArtWorkViewModel: Equatable {
    
    static func ==(lhs: ArtWorkViewModel, rhs: ArtWorkViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
            && lhs.link == rhs.link
            && lhs.artistType == rhs.artistType
    }
    
}
